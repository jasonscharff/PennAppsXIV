Lecture 2
9/8/16

### Overview
* Recursive Algorithms
* Divide and Conquer
  * Merge Sort
* Solving (time) recurrrences
___
## Recursive Algorithms
__Idea__: Reduce problem to a smaller instance
Looking at Insertion Sort:
1. Recursively sort the first $n-1$ elements
2. Insert the $n^{th}$ element in the right position.
$$
T(n) =
\begin{cases}
T(n-1) + \theta(n) & \text{for } n \gt 1\\
\theta(1) & \text{for } n = 1 \\
\end{cases}
$$
Expanding the recursion:
$$
\begin{align}
T(n) & = T(n-1) + cn \\
& = T(n-2) + c(n-1) + cn \\
& = c + 2c + ... + c(n-1) + cn \\
& = c(\frac{n(n+1)}{2}) \\
& = c\frac{n^2}{2} + c\frac{n}{2} \\
& = \theta(n^2)
\end{align}
$$
___
### Divide and Conquer
1. __Divide__ into smaller *subproblems*
2. __Conquer__
3. __Combine__

Analyzing the __Merge Sort__ algorithm
$$
T(n) =
\begin{cases}
T(n/2) + T(n/2) + \theta(n) & \text{for } n \gt 1 \\
\theta(1) & \text{for } n = 1\\
\end{cases}
$$
$$
\begin{align}
T(n) & = cn + 2T(n/2) \\
& = cn + 2(\frac{cn}{2}) + 4T(n/4) \\
& = cn + 2(\frac{cn}{2}) + 4(\frac{cn}{4}) + ... \\
& = cn(\log{n} + 1) \\
& = \theta(n\log{n})
\end{align}
$$

To prove that Merge Sort is still $n\log{n}$ given that n is NOT a power of two:
1. Use strong induction to prove lemma that merge sort is monotonically increasing
2. Assuming that $k = \lfloor{\log{n}}\rfloor$, show that $c2^k(k+1) < T(n) < c2^{k+1}(k+2)$

___
### Solving Recurrences
[MIT OCW](http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-042j-mathematics-for-computer-science-fall-2010/readings/MIT6_042JF10_chap10.pdf)
