#define     PILA_VACIA      -1
#define     MEMORIA_LLENA      -1
#define     OK              1

typedef struct s_nodo
{
    int dato;
    struct s_nodo *sig;
}t_nodo;

typedef t_nodo* t_pila;

void crearPila(t_pila*);
int pila_llena(const t_pila*);
int apilar(t_pila*,const int);
int pila_vacia(const t_pila*);
int desapilar(t_pila*);
int ver_tope(const t_pila*, int);
void vaciar_pila(t_pila*);
void mostrarPila(t_pila pila);
