import java.io.*;
import java.util.*;

// Code built from the template provided in lab09

public class BFS {
    /*This class is taken from geeksforgeeks.org*/
    static class FastReader {
        
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
    
    
    private int[] distance;
    private boolean[] visited;
    private Queue<Integer> q;
    
    
    public BFS(int n){
        distance = new int[n];
        visited = new boolean[n];
        
        for(int i = 0; i < n; i++){
            //distance[i] = Integer.MAX_VALUE;
            visited[i] = false;
        }
    }
    
    public ArrayList<Integer> buildAdjacent(boolean[] blocked, int i, int n){
        // get adjacent nodes on the fly
        ArrayList<Integer> adj = new ArrayList<>();
        //handle 0 division for 0%0
        if (i==0){
            //check right index; assume n>1
            if (!blocked[i+1]){
                adj.add(i+1);
            }
            // check below index
            if (!blocked[i+n]){
                adj.add(i+n);
            }
            return adj;
        }
        // handle bottom left corner
        else if (i==(n*n)-1){
            // check left index
            if (!blocked[i-1]){
                adj.add(i-1);
            }
            //check above index
            if (!blocked[i-n]){
                adj.add(i-n);
            }
            return adj;
        }

        //check left index
        if ((i%n-1 >=0) && !blocked[i-1]){
            adj.add(i-1);
        }
        //check right index
        if ((i%n <n-1) && !blocked[i+1]){
            adj.add(i+1);
        }
        //check above index
        if ((i-n >=0) && !blocked[i-n]){
            adj.add(i-n);
        }
        //check below index
        if ((i+n <n*n) && !blocked[i+n]){
            adj.add(i+n);
        }
        return adj;
    } 
    
    public int breadthFirstSearch(boolean[] blocked, int source, int target, int n){
        //code here
        int currentDistance = 0;
        int current;
        int index;
        visited[source]=true;
        distance[source]=0;
        // Initialize the queue
        q = new ArrayDeque();
        q.add(source);
        // main loop
        while (!q.isEmpty() && currentDistance < 575){
            current = q.poll();
            currentDistance = distance[current];
            //Build the adjacency list for this node on the fly
            ArrayList<Integer> adj = buildAdjacent(blocked, current, n);
            // iterate over each node adjacent to this
            for(int i=0;i<adj.size();i++){
                index = adj.get(i);
                if (!visited[index]){
                    visited[index]=true;
                    distance[index]=distance[current]+1;
                    q.add(index);
                }
            }
            visited[current]=true;
        }
        return distance[target];
    }
    
    
    public static void main(String[] args) throws Exception {
        FastReader in = new FastReader();
        int n = in.nextInt(); //node numbers are between 0 to n-1
        boolean[] blocked = new boolean[n*n];    // Used to track blockages and build edges
        int source=-1;
        int target=-1;
        
        //Get graph from input
        // First pass to populate blocked[] and locate source and target
        String line = "";
        for (int i=0; i<n;i++){
            line = in.nextLine();
            //System.out.println(line);
            for(int j=0;j<line.length();j++){
                char c = line.charAt(j);
                //System.out.println(c);
                // Check for unblocked pathways
                if (c=='.'){
                    blocked[i*n+j]=false;
                }
                // Check for blocked pathways
                else if (c=='#'){
                    blocked[i*n+j]=true;
                }  
                // Check for A
                else if (c=='A'){
                    source = i*n+j;
                    blocked[i*n+j]=false;
                    //System.out.println("Found Source");
                }
                // Check for B
                else if (c=='B'){
                    target = i*n+j;
                    blocked[i*n+j]=false;
                    //System.out.println("Found target");
                }  
            }
            
        }
        
        // Print the source and target
        //System.out.println(source);
        //System.out.println(target);
        // Print the array list
        //for (int i=0;i<n*n;i++){
        //    System.out.println(adj[i]);
        //}
        
        BFS bfs = new BFS(n*n);
        int distance = bfs.breadthFirstSearch(blocked, source, target, n);
        if (bfs.visited[target]){
            System.out.println(distance);
        }
        else{
            System.out.println("IMPOSSIBLE");
        }
        //bfs.printPath(target);
    }
}



