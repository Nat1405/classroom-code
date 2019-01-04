
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;


public class DFS {
    private boolean[] visited;
    private final int n;    
    
    public DFS(int n){
        this.n = n;
        visited = new boolean[n];
        
        for(int i = 0; i < n; i++){
            visited[i] = false;
        }
    }
    
    public int depthFirstSearch(List<Integer>[] adj){
        //count the number of connected components as well
        int connected = 0;
        for(int i = 0; i < n; i++){
            if(visited[i] == false){
                connected ++;
                dfsRecursive(adj, i);
            }
        }
        return connected;
    }
    
    public void dfsRecursive(List<Integer>[] adj, int x){
        //code here
        int adjacentNode;
        visited[x] = true;
        for (int i=0; i<adj[x].size();i++){
            adjacentNode = adj[x].get(i);
            if (!visited[adjacentNode]){
                dfsRecursive(adj, adjacentNode);
            }
        }
    }
    
    public static void main(String[] args) throws Exception {
        Scanner in = new Scanner(System.in);
        int n = in.nextInt(); //node numbers are between 0 to n-1
        
        
        List<Integer>[] adj = new List[n];
        for (int i = 0; i < n; i++) {
            adj[i] = new ArrayList<>();
        }
        
        //read the input graph here
        int numAdjacent = 0;
        for (int i=0; i<n; i++){
            // get number of nodes
            numAdjacent = in.nextInt();
            for (int j = 0; j<numAdjacent; j++){
                adj[i].add(in.nextInt());
            }
        }

        DFS dfs = new DFS(n);
        int components = dfs.depthFirstSearch(adj);
        System.out.println("Number of components: ");
        System.out.println(components);//number of connected components
    }
}