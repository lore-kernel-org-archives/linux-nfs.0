From: "Steve Wolfe" <nw@codon.com>
Subject: rpc.statd and port usage...
Date: Fri, 22 Mar 2002 12:13:59 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <002201c1d1d5$bb9f40e0$d281f6cc@iboats.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Received: from local.iboats.com ([204.246.129.200])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16oUUN-0002qd-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Mar 2002 11:14:11 -0800
To: <nfs@lists.sourceforge.net>
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
