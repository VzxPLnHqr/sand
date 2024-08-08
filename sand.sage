# this file can be loaded in the sage repl by running:
# sage: sage.repl.load.load("sand.sage",globals())

def holegrid(m,n,p = 0.0):
     G = graphs.Grid2dGraph(m+2, n+2)
     G.allow_multiple_edges(True)

     # get the outer bordering vertices
     # and we will later merge them with the (0,0) sink
     V = [(i,j) for i in [0,m+1] for j in range(n+2)]
     V += [(i,j) for j in [0,n+1] for i in range(m+2)]
     # probabilisitcally select some vertices but only from
     # the inside of the grid, not any of the outer cells
     for i in range(1,m+1):
         for j in range(1,n+1):
             if p >= random():
                  V += [(i,j)]
     # merge the selected vertices V with the sink
     G.merge_vertices(V)
     return G
 
def holegrid_prime(m,n,min_bits=0,p=0.1):
  """
  Build an m by n grid which, when treated as a sandpile
  has a sandpile group with a prime order. This is done
  by changing some of the innner nodes to sink nodes.
  """
  iteration = 0 
  while True:
      G = holegrid(m,n,p)
      S = Sandpile(G,(0,0))
      order = S.group_order()
      prime = order.is_prime()
      if mod(iteration, 100) == 0:
        print(iteration, order.bit_length(), order.is_prime())
      if prime and order > min_bits:
          print(iteration, order.bit_length(), order.is_prime())
          return G
      iteration += 1


def multiply_by_scalar(c,k,verbose=False):
  """
  multiply a sandpile config c by a non-negative integer k and return the
  final configuration. We do this by using the "double and add" recursive
  algorithm.

  INPUT:
    c: SandpileConfig
    k: Int -- non-negative integer

  OUTPUT:
    SandpileConfig
  """

  global topplings, cancellations # ugly hack
  topplings = 0
  cancellations = 0
  
  def removeIdentity(c):
    # whenever we can, we remove a copy of the identity
    # configuration before stabilizing
      global cancellations
      res = (c - c.sandpile().identity())
      if( all(i >= 0 for i in res.values()) ):
        cancellations += 1
        return res
      else:
        return c

  def cAdd(c1, c2):
      global topplings
      [res, fv] = removeIdentity((c1 + c2)).stabilize(with_firing_vector=True)
      ts = sum(fv.values())
      topplings += ts
      return res
  def cDouble(c):
      global topplings
      [res, fv] = removeIdentity((c + c)).stabilize(with_firing_vector=True)
      ts = sum(fv.values())
      topplings += ts
      return res
  
  def f(accum, k):
      if k == 0:
          return c.sandpile().identity()
      elif k == 1:
          return accum
      elif mod(k,2) == 1:
          return cAdd(accum,f(accum, k - 1))
      else:
          return f(cDouble(accum), k // 2)
      
  res = f(c,k) # triggers modifying global topplings variable, uggly hack.
  if verbose: print("topplings: ", topplings, "cancellations: ", cancellations)
  return res