From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: ~800 mountpoint limitation
Date: Fri, 17 Oct 2003 08:09:56 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127F56@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AAWFb-00012g-00
	for <nfs@lists.sourceforge.net>; Fri, 17 Oct 2003 08:10:47 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1AAWFX-0002Jj-L5
	for nfs@lists.sourceforge.net; Fri, 17 Oct 2003 08:10:43 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

> The main point with putting all the transport to a given server on one
> socket is that the UDP/TCP congestion control algorithms can then
> function efficiently. Instead of competing against other packets
> originating from itself, the client only has to deal with competition
> from other clients.

i guess i would buy that if someone could convince me the RPC client
would actually do fair load balancing if given the opportunity.  my
own experience with multi process workloads is that we aren't there
yet.  in other words, TCP is *designed* to handle network contention,
so i don't have a problem letting multiple sockets from the same
client duke it out for network bandwidth.

i also have some SMP scalability concerns.  using a single transport
means we have many processes on several CPUs that are contending
for the socket buffer space, the socket and xprt locks, and that are
holding the BKL while issuing RPCs.

i know that NFSv4 is designed to work with a single connection to
a server... so this is coming whether i like it or not  :^)  i hope
we can arrive at a design that addresses the NFSv4 requirements and
increases the per-client mount limit substantially, but does not
suffer from the scalability issues i have raised.


-------------------------------------------------------
This SF.net email sponsored by: Enterprise Linux Forum Conference & Expo
The Event For Linux Datacenter Solutions & Strategies in The Enterprise 
Linux in the Boardroom; in the Front Office; & in the Server Room 
http://www.enterpriselinuxforum.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
