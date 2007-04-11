From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: cel's patches under development
Date: Wed, 11 Apr 2007 07:39:53 -0400
Message-ID: <EXNANE01OF9vJZTuG5w00000863@exnane01.hq.netapp.com>
References: <460852BB.4080503@oracle.com>
	<200704101722.13798.olaf.kirch@oracle.com>
	<1176233539.309.27.camel@heimdal.trondhjem.org>
	<200704110841.21291.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbbAr-0000h8-KY
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 04:39:41 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbbAt-00041E-JS
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 04:39:44 -0700
In-Reply-To: <200704110841.21291.olaf.kirch@oracle.com>
References: <460852BB.4080503@oracle.com>
	<200704101722.13798.olaf.kirch@oracle.com>
	<1176233539.309.27.camel@heimdal.trondhjem.org>
	<200704110841.21291.olaf.kirch@oracle.com>
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

At 02:41 AM 4/11/2007, Olaf Kirch wrote:
>On Tuesday 10 April 2007 21:32, Trond Myklebust wrote:
>> Also, what about stuff like RDMA, which doesn't need this sort of
>> mechanism in order to get things right?
>
>But RDMA may benefit from the proposed interface for transport
>specific receive buffers (rpc_data objects). How that buffer works is
>entirely up to the transport. For TCP and UDP it's skb_lists, but for
>RDMA it would probably be something very different.

FWIW, I'm still looking at this from the RDMA perspective. I like the
abstraction of the data representation, but I don't like the protocol
specific switch statements that are in the data movement. These
are cumbersome and don't lend themselves to dynamic loading. Also,
RDMA isn't a new protocol family, so it doesn't lend itself to an
IPv4/IPv6 and UDP/TCP kind of switch.

>Here's the mode of operation - XDR functions that expect to receive
>data to a pagevec, such as READ, READLINK etc, call
>xprt_rcvbuf_alloc(xprt, pages, pgbase, pglen) to allocate a
>transport specific buffer object. Transports such as TCP or UDP
>ignore the page vector, but the RDMA transport could use this
>to do set up its buffers. From the implementation point of view,

The RDMA code turns out to not need this, because the xdr iov's
have a clear encoding for pagelists (head->pages[]->tail). The only
ambiguity comes from the upper layer - NFS READDIRs for example
send down a pagelist, but they don't expect to cache the result
directly like for READ. We use a different RDMA operation for them,
and there's a guess made at the lower layer. However, moving this
function to XDR doesn't fix it. So I'm semi-neutral on the proposed
change from the RDMA perspective.

>I believe the net result of this proposed restructuring will be
>less complexity. Right now we have half a dozen or so
>functions that walk through an xdr_buf (head, pagevec, tail)...
>whereas with the proposed changes, you have the complexity
>confined to one place.

This is good, but I'd like to see a stronger benefit, personally. More
comments after I get a better look.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
