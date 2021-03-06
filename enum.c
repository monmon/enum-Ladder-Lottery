#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<math.h>
#define CHECK 1000000000

// Structures
// A vertex
typedef struct vertex{
  struct vertex *up;
  struct vertex *down;
  struct vertex *left;
  struct vertex *right;
  int line, routeNum;  // line number and route number
} vertex;

// A bar
typedef struct bar{
  struct vertex *left;
  struct vertex *right;
  struct vertex *activeBar;
  struct bar *next;
  struct bar *prev;
} bar;


//
// Global variables
//
int perm[20];
int n;
vertex *upper;  // The upper endpoints of lines
vertex *lower;  // The lower endpoints of lines
int *startLines;
vertex *activeBar = NULL;  // Current active bar
double temp;

// Stack of bars
bar *head = NULL;
bar *tail = NULL;

double count = 0;

int withPrint = 0;

//
// Prototypes
//
inline void init();
void simplePrint();

inline void makeRoot();
void findAllChildren(int);
void leftswap(vertex*, vertex*);
void rightswap(vertex*, vertex*);
int isLeftswappable(vertex*, vertex*);
int isRightswappable(vertex*, vertex*);

inline void insertBar(vertex*, vertex*, vertex*, vertex*, vertex*, vertex*);

inline void push(bar*);
inline bar* pop();

void print();


/*
  Main routine
 */
int main(int argc, char* argv[])
{
  int i;
  clock_t time[2];

  if (*argv[1] == 'p') {

    withPrint = 1;
    n = argc - 2;
    printf("withPrint = 1\n");
    printf("n=%d\n",n);
    for (i=1; i<=n; i++)  {
      perm[i] = atoi(argv[i+1]);
    }

  } else {

    withPrint = 0;
    n = argc - 1;
    
    printf("n = %d\n",n);
    
    for (i=1; i<=n; i++) {
      perm[i] = atoi(argv[i]);
    }
  }

  printf("\nThe input permutation:\n");
  for (i=1; i<=n; i++) {
    printf("perm[i]:%d ", perm[i]);
  }
  printf("\n");

  time[0] = clock();
  init();
  makeRoot(); count++;
  findAllChildren(1);
  time[1] = clock();

  //count = 2000000000;
  //count = count * 3;
  //count = count * 1000;
  //count++;
  //count = count + 5555;
  //count = count - 4400;
  //count = count * 2;

  printf("Count = %.0f\n", count);
  printf("Time to enumerate: %.2f sec\n",
         (double)(time[1]-time[0])/CLOCKS_PER_SEC);
}



/*
  Initialize above[], below[], startLines[].
*/
void init()
{
  int i;

  upper = (vertex*)malloc(sizeof(vertex[n+1]));
  lower = (vertex*)malloc(sizeof(vertex[n+1]));

  // An error ?
  for (i=n; i>=1; i--) {
    upper[i].down = &lower[i];
    upper[i].up = upper[i].left = upper[i].right = NULL;
    upper[i].line = i; upper[i].routeNum = 0;
    lower[i].up = &upper[i];
    lower[i].down = lower[i].left = lower[i].right = NULL;
    lower[i].line = i; lower[i].routeNum = 0;
  }

  startLines = (int*)malloc(sizeof(int[n+1]));
  printf("startLines = %.0f\n", startLines);
}



/*
  Simple print method
 */
void simplePrint()
{
  int i;
  vertex *curr;

  for (i=n; i>=1; i--) {
    curr = &upper[i];
    printf("%d: ",i);
    while (curr != NULL) {
      printf("%d ",curr->line);
      curr = curr->down;
    }
    printf("\n");
  }
  printf("\n");
}



/*
 Construct root amida
*/
void makeRoot()
{
  int currNum;  // current number
  int startLine = 1, restartLine;
  int i, diff;
  vertex *currVertex, *upperVertex, *lowerVertex;
  vertex *leftNewVertex, *rightNewVertex;

  for (currNum=n; currNum >= 1; currNum--) {

    // Calc of the zigzag-path for currNum.
    printf("currNum = %d\n", currNum);
    while (perm[startLine] != currNum) {
      startLine++;
      printf("startLine = %d, ",startLine);
    }

    // Construct startLines[]
    startLines[currNum] = startLine;
    printf("startLines[currNum] = %d\n", startLines[currNum]);

    // Move to down
    currVertex = &upper[startLine];
    restartLine = startLine;
    while (currVertex->down != NULL) {
      if (currVertex->left != NULL) { 
        currVertex = currVertex->left;
        restartLine--;
      } else {
        currVertex = currVertex->down;
      }
    }


    // Make zigzag-path for currNum.
    // We insert a new vertex between upperVertex and lowerVertex.
    upperVertex = currVertex->up;
    lowerVertex = currVertex;
    

    for (i = restartLine; i < currNum; i++) {
      printf("for currNum = %d: i = %d\n", currNum, i);
      leftNewVertex = (vertex*)malloc(sizeof(vertex));
      rightNewVertex = (vertex*)malloc(sizeof(vertex));

      leftNewVertex->line = i;
      leftNewVertex->routeNum = currNum;
      rightNewVertex->line = i+1;
      rightNewVertex->routeNum = currNum;
      
      insertBar(upperVertex, lowerVertex, lower[i+1].up, 
                &lower[i+1], leftNewVertex, rightNewVertex);
      
      // Update of upperVertex and lowerVertex.
      upperVertex = rightNewVertex;      
      lowerVertex = &lower[i+1];
    }

    startLine = 1;
    printf("\n");
  }

  printf("\n\n");
  
  for (i = 1; i < n; i++) {
    printf("for startLines[%d]: %d\n", i, startLines[i]);
  }

  for (i=1; i<=n; i++) {
    printf("i = %d:\n", i);
    currVertex = &upper[i];
    while (currVertex->down != NULL) {
      printf("line = %d:\n", currVertex->line);
      currVertex = currVertex->down;
    }
    printf("line = %d:\n", currVertex->line);
  }
  for (i=1; i<=n; i++) {
    printf("i = %d:\n", i);
    currVertex = &lower[i];
    while (currVertex->up != NULL) {
      printf("line = %d:\n", currVertex->line);
      currVertex = currVertex->up;
    }
    printf("line = %d:\n", currVertex->line);
  }

}



void insertBar(vertex *upperleft, vertex *lowerleft, vertex *upperright, 
               vertex *lowerright, vertex *leftend, vertex *rightend)
{
  upperleft->down = leftend;
  lowerleft->up   = leftend;

  upperright->down = rightend;
  lowerright->up = rightend;

  leftend->up = upperleft;
  leftend->left = NULL;
  leftend->down = lowerleft;
  leftend->right = rightend;

  rightend->up = upperright;
  rightend->left = leftend;
  rightend->down = lowerright;
  rightend->right = NULL;
}



/*
  Find all children
 */
void findAllChildren(int cleanLevel)
{
  vertex *x,*y, *currVertex, *upperleft, *lowerleft;
  int i, state, route, currCleanLevel = cleanLevel;
  bar b, *b2;

  // Omit for efficiency @ 8th.Apr.2009.
  if (withPrint == 1) {
    printf("cleanLv = %d:\n", cleanLevel);
    printf("%d-th amida", count);
    printf("cleanLv = %d:\n", cleanLevel);
    print();  // Count & Print
   }

  for (i=1; i<=n; i++) {
    printf("i = %d:\n", i);
    currVertex = &upper[i]; 
    while (currVertex->down != NULL) {
      printf("line = %d:\n", currVertex->line);
      currVertex = currVertex->down;
    }
    printf("line = %d:\n", currVertex->line);
  }
  for (i=1; i<=n; i++) {
    printf("i = %d:\n", i);
    currVertex = &lower[i]; 
    while (currVertex->up != NULL) {
      printf("line = %d:\n", currVertex->line);
      currVertex = currVertex->up;
    }
    printf("line = %d:\n", currVertex->line);
  }

  // Turn bar children
  for (i=n; i>=currCleanLevel-1; i--) {
    // find turn bar for route of i.
    // state = 0: go to lowerleft 
    // state = 1: stop state

    // If cleanLv = 1 then, we have error case: i = 0!.
    if (i==0) continue;
    
    currVertex = &upper[startLines[i]]; 
    state = 0;  // 0: Go to lower-left, 1: stop(find turn bar)

    while (state != 1) {
      currVertex = currVertex->down;
      if (currVertex->left != NULL) {
        currVertex = currVertex->left;
      }
      else
        state = 1;
    }
    if (currVertex->right == NULL) {
      continue;
    }
    // We have just found the turn bar of route i.





    printf("1line: %d\n", currVertex->line);
    while (currVertex->line != i) {
      printf("2line: %d\n", currVertex->line);
      lowerleft = currVertex->down;  // Find lower-left vertex of current vertex

      if (lowerleft->right == NULL) {
        printf("pre3line: %d\n", currVertex->line);
        currVertex = currVertex->right;
        currVertex = currVertex->down;
        printf("3line: %d\n", currVertex->line);
        continue;    // increment & continue (skip recursive call)

      } else if ( isRightswappable(lowerleft, lowerleft->right) ) {
        if (i == cleanLevel-1) {
          printf("4line: %d\n", currVertex->line);

          if (lowerleft->line + 2 < activeBar->line ) {
            printf("5line: %d\n", currVertex->line);
            ;  //break;
          } else {
            printf("6line: %d\n", currVertex->line);

            route = currVertex->routeNum;
            b.left = lowerleft; b.right = lowerleft->right;
            b.next = b.prev = NULL;
            b.activeBar = activeBar;
            push(&b);
            
            rightswap(lowerleft,lowerleft->right);
            
            activeBar = lowerleft; // Update of active bar
            count++;  // Count up
            
            // Written in 9th.Apr.2009
            temp = fmod(count, CHECK);
            if (temp == 0) {
              printf("The %.0f-th amida was generated\n",count);
            }
            
            // Recursive call
            findAllChildren(route + 1);
            
            b2 = pop();
            leftswap(b2->left,b2->right);  // Return to the parent
            activeBar = b2->activeBar;  // Return to the parent
          }

        } else {  // Case of i >= cleanLevel-1
          printf("7line: %d\n", currVertex->line);
          
          route = currVertex->routeNum;
          b.left = lowerleft; b.right = lowerleft->right;
          b.next = b.prev = NULL;
          b.activeBar = activeBar;
          push(&b);
          
          rightswap(lowerleft,lowerleft->right);
          
          activeBar = lowerleft; // Update of active bar
          count++;  // Count up
          
          // Recursive call
          findAllChildren(route + 1);
          
          b2 = pop();
          leftswap(b2->left,b2->right);  // Return to the parent
          activeBar = b2->activeBar;  // Return to the parent
        }
      }

      printf("===================\n");
      // increment currVertex
      currVertex = currVertex->right;
      currVertex = currVertex->down;
      printf("8line: %d\n", currVertex->line);
    }  // while

  } // for loop (biggest loop in this subroutine.)

}


/*
  rightswap and leftswap
 */
void rightswap(vertex *left, vertex *right)
{
  vertex *a,*b,*c,*d,*e,*f,*g,*h;

  a = left->up;
  c = right->up;
  b = c->up;
  d = c->right;

  e = left->down;
  f = right->down;
  g = b->up;
  h = d->up;

  // Remove left and right.
  e->up = a;
  a->down = e;
  f->up = c;
  c->down = f;

  // Add left and right to new places.
  b->up = left;
  left->down = b;
  left->up = g;
  g->down = left;

  d->up = right;
  right->down = d;
  right->up = h;
  h->down = right;

  left->line = left->line + 1;
  right->line = right->line + 1;
}

void leftswap(vertex *left, vertex *right)
{
  vertex *a,*b,*c,*d,*e,*f,*g,*h;

  e = left->up;
  f = right->up;

  b = left->down;
  a = b->left;

  c = b->down;
  d = right->down;

  g = a->down;
  h = c->down;

  // remove left and right
  e->down = b;
  b->up = e;
  f->down = d;
  d->up = f;

  // add left and right
  c->down = right;
  right->up = c;
  right->down = h;
  h->up = right;

  a->down = left;
  left->up = a;
  left->down = g;
  g->up = left;

  left->line = left->line - 1;
  right->line = right->line - 1;
}


/*
  isRightswappable and is Leftswappable
 */
int isRightswappable(vertex *left, vertex *right)
{
  vertex *leftup = left->up;
  vertex *rightup = right->up;

  if (leftup->up == NULL) return 0;
  else if (right->up == NULL) return 0;
  else if ( (leftup->left == NULL) && (rightup->left == NULL) 
             && ( leftup->right == rightup->up )) return 1;
  else return 0;
}

int isLeftswappable(vertex *left, vertex *right)
{
  vertex *leftdown = left->down;
  vertex *rightdown = right->down;

  if (leftdown->down == NULL) return 0;
  else if (rightdown->down == NULL) return 0;
  else if ( (leftdown->right == NULL) && (rightdown->right == NULL) &&
            ( leftdown->down == rightdown->left ) ) return 1;
  else return 0;
}



/*
  Operations for Stack
 */
void push(bar *b)
{
  if ( (head == NULL) && (tail == NULL) ) {
    head = tail = b;
    b->next = NULL;
    b->prev = NULL;
  } else  if (head == tail) {
    head = b;
    b->next = tail;
    tail->prev = b;
  } else {
    head->prev = b;
    b->next = head;
    b->prev = NULL;
    head = b;
  }
}

bar* pop()
{
  bar *temp;

  if ( (head == NULL) && (tail == NULL) ) {
    return NULL;
  } else if (head == tail) {
    temp = head;
    head = tail = NULL;
    return temp;
  } else {
    temp = head;
    head = head->next;
    head->prev = NULL;
    return temp;
  }
}



/*
  Print amidas
*/
void print()
{
  vertex **current;
  int i,j;
  int wasPrinted[n+1]; // 0: not printed in the previous loop.
                       // 1: surely printed in the previous loop.
  int final = 0;

  current = (vertex**)malloc(sizeof(vertex*[n+1]));
  
  // Initialization
  for (i=1; i<=n; i++) {
    current[i] = &upper[i];
    wasPrinted[i] = 1;
  }

  while (final != n) {
    
    final = 0;
    
    // 1st: Go down phase.
    for (i=1; i<=n; i++) {
      if (wasPrinted[i]==1) { 
        if (current[i]->down != NULL) {
          current[i] = current[i]->down;
        } else {
          final++;
        }
        wasPrinted[i] = 0;
      }
    }

    // 2nd: Print phase.
    for (i=1; i<=n-1; i++) {
      printf("|");
      if ( current[i]->right == current[i+1] ) {
        printf("-");
        wasPrinted[i] = 1;
        wasPrinted[i+1] = 1;
      }else {
        printf(" ");
      }
    }
    printf("|\n");

    // 3rd: Check final or not.
    for (i=1; i<=n; i++) {
      if (current[i] == &lower[i]) {
        final++;
      }
    }

  }

  printf("\n");

}
