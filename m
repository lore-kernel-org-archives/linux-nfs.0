From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: ~800 mountpoint limitation
Date: Fri, 17 Oct 2003 12:41:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16272.7101.893073.601152@charged.uio.no>
References: <482A3FA0050D21419C269D13989C6113127F56@lavender-fe.eng.netapp.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AAXkH-0002BK-00
	for <nfs@lists.sourceforge.net>; Fri, 17 Oct 2003 09:46:33 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1AAXia-0003FF-CI
	for nfs@lists.sourceforge.net; Fri, 17 Oct 2003 09:44:48 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113127F56@lavender-fe.eng.netapp.com>
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

>>>>> " " == Charles Lever <Lever> writes:

     > i guess i would buy that if someone could convince me the RPC
     > client would actually do fair load balancing if given the
     > opportunity.  my own experience with multi process workloads is
     > that we aren't there yet.

Load balancing is a policy problem for the higher levels. The RPC
layer doesn't carry any information about task priorities beyond the
most basic FIFO-style queueing. Why should it?

     > in other words, TCP is *designed* to handle network contention,
     > so i don't have a problem letting multiple sockets from the
     > same client duke it out for network bandwidth.

The slow-start algorithm is not an optimal method for dealing with
contention. Every time you collide, you a forced to growth the
bandwidth linearly from zero up to 1/2 that you initially had before
you collided. After that, you grow using a 1/n rule.
In practice, therefore, you will tend to find it faster if you shunt
everything through the same TCP socket and avoid the collision in the
first place.

Then, with TCP, there's also the issue of reconnections. If the server
starts dropping TCP connections in order to deal with a resource
starvation issue, reconnection is an expensive operation.

IOW: lack of scalability can be a performance problem too...

     > i also have some SMP scalability concerns.  using a single
     > transport means we have many processes on several CPUs that are
     > contending for the socket buffer space, the socket and xprt
     > locks, and that are holding the BKL while issuing RPCs.

That problem has nothing to do with the issue of multiple sockets or
not. The BKL is held over all RPC calls. I have yet to see numbers
showing that the socket/xprt locks are a major contention problem.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email sponsored by: Enterprise Linux Forum Conference & Expo
The Event For Linux Datacenter Solutions & Strategies in The Enterprise 
Linux in the Boardroom; in the Front Office; & in the Server Room 
http://www.enterpriselinuxforum.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
