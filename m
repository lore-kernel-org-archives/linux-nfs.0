From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: cel's patches under development
Date: Wed, 11 Apr 2007 14:02:49 +0200
Message-ID: <200704111402.50435.olaf.kirch@oracle.com>
References: <460852BB.4080503@oracle.com>
	<200704110841.21291.olaf.kirch@oracle.com>
	<EXNANE01OF9vJZTuG5w00000863@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbbY9-0003Kq-Ai
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 05:03:45 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HbbYA-0002bH-Hb
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 05:03:47 -0700
In-Reply-To: <EXNANE01OF9vJZTuG5w00000863@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wednesday 11 April 2007 13:39, Talpey, Thomas wrote:
> FWIW, I'm still looking at this from the RDMA perspective. I like the
> abstraction of the data representation, but I don't like the protocol
> specific switch statements that are in the data movement. These

Right now, the proposed rpc_data thing has two function pointers,
so no switch needed.

> are cumbersome and don't lend themselves to dynamic loading. Also,
> RDMA isn't a new protocol family, so it doesn't lend itself to an
> IPv4/IPv6 and UDP/TCP kind of switch.

How is it integrated on the client side? Wouldn't this be another
transport in terms of Chuck's transport switch? If so, it would just
provide a function for creating an RDMA specific rpc_data object
that does the right thing.

> The RDMA code turns out to not need this, because the xdr iov's
> have a clear encoding for pagelists (head->pages[]->tail).

But that means yet another non-obvious user of xdr_buf that makes
it even harder to rewrite that whole code :-) Wouldn't it be better
to make it explicit "here is a bunch of pages that I want you to
put the bulk data into"?

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
