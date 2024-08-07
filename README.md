## Cryptography with Sandpiles

If you are unfamiliar with Abelian sandpiles, you may want to [watch this Numberphile video](https://www.youtube.com/watch?v=1MtEUErz7Gg) all the way to the end, and/or [read the Wikipedia page](https://en.wikipedia.org/wiki/Abelian_sandpile_model).

Then the following might make more sense:

Can we create a grid, perhaps with some missing cells, which can be used as the
basis for an abelian sandpile model? Yes.

Can such a grid be found where the resulting Sandpile Group is of prime order? Yes.

Can the bit length of the group order be greater than 256 bits? Yes.

Can we use it for cryptography? Probably not.[^2] But maybe?

Anyway, here is the grid:

```
$ git clone <this repo> sandpiles
$ cd sandpiles

# install sage (or just run it with "nix run nixpkgs#sage")
$ sage

# now in the sage math repl
# this tutorial is also helpful: https://doc.sagemath.org/html/en/thematic_tutorials/sandpile.html
# but it can be skipped for now

# load the graph provided in this repo
sage: graph = load("holegrid-m13-n15-p10-320bits-graph.sobj")

# see what the 13x15 grid with some cells missing looks like
sage: graph.show('js')

# create a Sandpile from the graph using the (0,0) vertex as the sink
sage: sandpile = Sandpile(G,(0,0))

# notice how the order of the sanpile group is a very large prime
sage: sage: sandpile.group_order().bit_length()
320
sage: sandpile.group_order().is_prime()
True

# for a cyclic group of prime order, any non-identity element is a generator
# here we just use whichever generator the library found for us
# we call our generator G
sage: G = SandpileConfig(sandpile,sandpile.group_gens(0)[0])

# adding two sandpile configurations together and then stabilizing is another sandpile
(G + G).stabilize()

# the identity sandpile configuration is conveniently made available too
# we use the letter O for our idenity element to remind us that it behaves like
# zero in addition
sage: O = sandpile.identity()

# just like with elliptic curve cryptography, 
# Alice and Bob select private keys a,b respectively
# and generate public keys (sandpile configurations!) A,B respectively
sage: a = randint(1,sandpile.group_order()-1)
sage: A = a*G
sage: b = randint(1,sandpile.group_order()-1)
sage: B = b*G

# Alice and Bob generate and exchange their public keys (their sandpiles)
# Now they can do the usual things like independently derive a shared secret:
sage: a*B == b*A
True

# TODO: use the sandpile group to construct a hash function and schnorr signatures
```

### Why? - a step toward low-tech cryptography?

The rules of the abelian sandpile model, especially when restricted to a 2D grid
of cells are easy enough that even a child can learn how to perform the stabilization
procedure. 

Now, having the patience to complete the hundreds of thousands of toppling
operations without error is an entirely different question. Nevertheless, this seems
like something a mechanical machine could do.

### References

1. Play with sandpiles with sage math - https://doc.sagemath.org/html/en/thematic_tutorials/sandpile.html

2. S. R. Blackburn, Cryptanalysing the critical group: efficiently solving Biggs’s discrete logarithm problem, J. Math. Crypt. 3 (2009), pp. 199–203. https://eprint.iacr.org/2008/170.pdf

3. F. Shokrieh, The Monodromy Pairing and Discrete Logarithm on the Jacobian of Finite Graphs (2010) https://arxiv.org/pdf/0907.4764

4. N.L. Biggs, ‘The critical group from a cryptographic perspective’, Bull.
London Math. Soc. 39 (2007) 829-836.