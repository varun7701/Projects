package apps;

import structures.*;
import java.util.ArrayList;

public class MST {
	
	/**
	 * Initializes the algorithm by building single-vertex partial trees
	 * 
	 * @param graph Graph for which the MST is to be found
	 * @return The initial partial tree list
	 */
	public static PartialTreeList initialize(Graph graph) {
	
		/* COMPLETE THIS METHOD */
		PartialTreeList toReturn = new PartialTreeList();
		for(Vertex v: graph.vertices) {
			PartialTree temp = new PartialTree(v);
			Vertex.Neighbor neighbor  = v.neighbors;
			while(neighbor != null) {
				PartialTree.Arc arc = new PartialTree.Arc(v,  neighbor.vertex, neighbor.weight);
				temp.getArcs().insert(arc);
				neighbor = neighbor.next;
			}
			
			toReturn.append(temp);
		}
		return toReturn;
	}

	/**
	 * Executes the algorithm on a graph, starting with the initial partial tree list
	 * 
	 * @param ptlist Initial partial tree list
	 * @return Array list of all arcs that are in the MST - sequence of arcs is irrelevant
	 */
	public static ArrayList<PartialTree.Arc> execute(PartialTreeList ptlist) {
		
		/* COMPLETE THIS METHOD */
		ArrayList<PartialTree.Arc> path = new ArrayList<PartialTree.Arc>();
		while(ptlist.size() > 1) {
			PartialTree ptx = ptlist.remove();
			MinHeap<PartialTree.Arc> pqx = ptx.getArcs();
			PartialTree.Arc temp = pqx.deleteMin();
			while(ptx.getRoot().getRoot().equals(temp.v2.getRoot())) {
				temp = pqx.deleteMin();
			}
			path.add(temp);
			PartialTree pty = ptlist.removeTreeContaining(temp.v2); 
			pty.getRoot().parent = ptx.getRoot().getRoot();
			ptx.merge(pty);
			ptlist.append(ptx);
		}
		return path;
	}
}
