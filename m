From: Chris Adams <chris@improbable.org>
Subject: nfsroot clients hang while mounting second NFS server
Date: Thu, 10 Jul 2003 18:23:57 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <57BDE604-B33E-11D7-A405-000A95703418@improbable.org>
Mime-Version: 1.0 (Apple Message framework v552)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [64.21.166.2] (helo=mail1.qwknetllc.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19amdm-0000Ep-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Jul 2003 18:24:02 -0700
To: nfs@lists.sourceforge.net
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

We have a small cluster using a single head node and a number of 
diskless compute nodes, all running 2.4.20-openmosix. We have an old 
NAS box which contains the NFS root filesystems for the compute nodes 
and our data directories. Now I'm trying to add another NAS box into 
the mix and have found it an easy way to kill our nodes.

Basic network connectivity is fine and rpcinfo / showmount on the nodes 
works as expected. No matter what options I use (hard/soft, tcp/udp, 
etc.) as soon as I try to mount the new server the nodes will hang. At 
that point they are still pingable but nothing higher level will 
respond and all open connections will fail.

Here's the total traffic I see from the new NAS server's perspective - 
10.0.73.29 is the node, 192.168.1.20 is the new file server:

  18   7.186921   10.0.73.29 -> 192.168.1.20 TCP 722 > sunrpc [SYN] 
Seq=2685755181 Ack=0 Win=5840 Len=0 MSS=1460 TSV=133216 TSER=0 WS=0
  19   7.187115   10.0.73.29 -> 192.168.1.20 TCP 722 > sunrpc [ACK] 
Seq=2685755182 Ack=2199399551 Win=5840 Len=0 TSV=133216 TSER=131447901
  20   7.187190   10.0.73.29 -> 192.168.1.20 Portmap V2 DUMP Call XID 
0x524a6869
  21   7.187581   10.0.73.29 -> 192.168.1.20 TCP 722 > sunrpc [ACK] 
Seq=2685755226 Ack=2199399951 Win=6432 Len=0 TSV=133216 TSER=131447901
  22   7.187703   10.0.73.29 -> 192.168.1.20 TCP 722 > sunrpc [ACK] 
Seq=2685755226 Ack=2199400751 Win=8000 Len=0 TSV=133216 TSER=131447901
  23   7.187875   10.0.73.29 -> 192.168.1.20 TCP 722 > sunrpc [ACK] 
Seq=2685755226 Ack=2199400875 Win=8000 Len=0 TSV=133216 TSER=131447901
  24   7.187900   10.0.73.29 -> 192.168.1.20 TCP 722 > sunrpc [FIN, ACK] 
Seq=2685755226 Ack=2199400875 Win=8000 Len=0 TSV=133216 TSER=131447901
  25   7.187999   10.0.73.29 -> 192.168.1.20 MOUNT V3 MNT Call XID 
0xe10349f
  26   7.188107   10.0.73.29 -> 192.168.1.20 TCP 722 > sunrpc [ACK] 
Seq=2685755227 Ack=2199400876 Win=8000 Len=0 TSV=133216 TSER=131447901
  27   7.199825   10.0.73.29 -> 192.168.1.20 Portmap V2 GETPORT Call XID 
0x1832c2fd
  30   7.200203 192.168.1.20 -> 10.0.73.29   Portmap V2 GETPORT Reply 
XID 0x1832c2fd

At that point the machine is dead and and the server won't see another 
packet from it. We're having some problems with the terminal server so 
I can't tell if it's dumping a panic to the serial console.

Is there a known problem with the in-kernel NFS support which might 
cause problems with multiple NFS servers? We aren't having problems on 
the other machines with the 2.4.20 kernel which makes me suspect the 
nfsroot support is involved somehow but I haven't found anything 
pertinent in my searches.

Thanks,
Chris



-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
