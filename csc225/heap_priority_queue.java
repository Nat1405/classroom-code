import java.io.*;
import java.util.*;
import java.lang.*;

/*This class is taken from geeksforgeeks.org*/
class FastReader {

    BufferedReader br;
    StringTokenizer st;

    public FastReader() {
        br = new BufferedReader(new InputStreamReader(System.in));
    }

    String next() {
        while (st == null || !st.hasMoreElements()) {
            try {
                st = new StringTokenizer(br.readLine());
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return st.nextToken();
    }

    int nextInt() {
        return Integer.parseInt(next());
    }

    long nextLong() {
        return Long.parseLong(next());
    }

    double nextDouble() {
        return Double.parseDouble(next());
    }

    String nextLine() {
        String str = "";
        try {
            str = br.readLine();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return str;
    }
}

public class Solution {

    public static void main(String[] args) throws Exception{
        /* Enter your code here. Read input from STDIN. Print output to STDOUT. Your class should be named Solution. */
        // get int n and int k
        FastReader reader = new FastReader();
        int n = reader.nextInt();
        int k = reader.nextInt();
        // get integer array of n integer gpas
        int[] A = new int[n];
        int i = 0;
        int n_copy = n;
        while (n_copy-- > 0)
        {
            A[i] = reader.nextInt();
            i++;
        }
        // Done; n is an int and A is array of ints of length n. Begin logic.
        
        BufferedWriter out = new BufferedWriter(new OutputStreamWriter(System.out));
        
        
        int p = 0;
        int r = k-1;
        int max_0 = 0;
        int max_1 = 0;
        
        // Make a heap of k initial elements
        
        
        PriorityQueue<Integer> pq = new PriorityQueue<>(Collections.reverseOrder());
        // load initial k elements into queue
        for (i=0; i<k; i++){
            pq.add(A[i]);
        }        
        
        while (r<n){
            // Grab the two largest elements of the priority queue.
            max_1 = pq.poll();
            max_0 = pq.poll();
            // Don't want to print a space on the last iteration
            out.write((max_0+max_1)+" ");
            // Break here
            if (r==(n-1)){
                break;
            }
            // add the second biggest value we popped back in
            pq.add(max_0);
            pq.add(max_1);
            // Worried about this line; is this O(k) time?
            pq.remove(A[p]);
            pq.add(A[r+1]);
            
            p++;
            r++;
        }
        
        
        //out.write(Integer.toString(n));
        //out.write(Integer.toString(k));
        //out.write(Arrays.toString(A));
        
        out.flush();
        

    }
}