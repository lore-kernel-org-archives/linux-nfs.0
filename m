From: "Bruce Allan" <bruce.allan@us.ibm.com>
Subject: Re: rpc.statd and port usage...
Date: Fri, 22 Mar 2002 11:33:59 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF6888EE9D.44F71D26-ON88256B84.006AFBD1@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, nfs-admin@lists.sourceforge.net
To: "Steve Wolfe" <nw@codon.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Use the -o and -p options to rpc.statd for outgoing requests and listening,
respectively.  See the manpage for statd.

---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



                                                                                                                                  
                      "Steve Wolfe"                                                                                               
                      <nw@codon.com>              To:       <nfs@lists.sourceforge.net>                                           
                      Sent by:                    cc:                                                                             
                      nfs-admin@lists.sour        Subject:  [NFS] rpc.statd and port usage...                                     
                      ceforge.net                                                                                                 
                                                                                                                                  
                                                                                                                                  
                      03/22/2002 11:13 AM                                                                                         
                                                                                                                                  
                                                                                                                                  





  On all of my machines, rpc.statd picks a (seemingly) random port < 1023,
but one machine is acting differently:  It will bind to one random port <
1023, then it will bind to both TCP and UDP on a high port, usually in the
32xxx range.

  Is that normal (or potentially normal) behavior, or should I be giving
heed to the red lights and sirens that are going off in my head?  If it is
potentially normal, how would I go about making it use only low,
priveliged ports, which are a lot easier to block at the firewall?

steve



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
