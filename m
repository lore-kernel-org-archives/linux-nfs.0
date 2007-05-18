From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,PATCH 3/14] knfsd: prepare reply per transport
Date: Fri, 18 May 2007 10:42:38 -0400
Message-ID: <1179499358.6488.66.camel@heimdal.trondhjem.org>
References: <20070517075342.GG27247@sgi.com>
	<7619F3097FAB384287CF636FF92D0CA10976B38B@exsvl01.hq.netapp.com>
	<20070518031630.GB5104@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	"Iyer,  Rahul" <Rahul.Iyer@netapp.com>,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp3fR-0005rr-SG
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 07:42:53 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/ZdKv5N6j9qYVqKwuDDB1BvnATKrqJG+M=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hp3fS-0005hB-2G
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 07:42:56 -0700
In-Reply-To: <20070518031630.GB5104@sgi.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-05-18 at 13:16 +1000, Greg Banks wrote:
> A very sensible thing to do, but hard to retrofit to the existing Linux
> code without significant surgery.  As you've discovered, the server and
> client code are two mostly-separate code bases (with mostly-separate
> authors and maintainers) that happen to link into the same module.
> Unifying these would be a major job.  I'd love to see it happen, for
> example to unify the XDR buffering code, but it would be an uphill
> battle technically and possibly politically also.  For some reason,
> code (like lockd) that lives in both the server and client side tends
> to be neglected by both camps.
> 
> > Given this, a unified transport switch would really rock. 
> > [...] Maybe I'm oversimplifying, but this seems doable.
> 
> Yes...eventually.

I'm not sure that politics is really the problem here. I think the
biggest issue is that the client and server have very different
workloads.

The job of the client is to pump as much data as fast as possible
through a single socket, to place incoming data into the correct reply
buffers as quickly and efficiently as possible, and to handle exceptions
such as dropped connections, or socket buffer starvation by resending
the request after reconnecting/waiting for the socket buffer to empty.
It uses a single workqueue, and non-blocking I/O in order to achieve
this goal.

The job of the server is to listen for new connections, to round-robin
through several sockets, to read incoming data into pre-allocated
anonymous buffers, to process the RPC call, then to pump out the result
as quickly as possible. It handles exceptions like dropped connections
by dropping the request and moving on. Resource starvation is handled by
deferring handling the request and/or possibly dropping it altogether.

Apart from the tasks of 'reading data' and 'writing data', it is hard to
see much that could be shared. Even for the case of reading/writing, the
code differs due to the client's need to identify the incoming request
or the server's need to provision socket write resources.
So if anyone is serious about wanting to share transport switches
between client and server, then what is first needed is a detailed
analysis of what actually _can_ be shared. After that we can discuss
what it actually makes sense to share.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
