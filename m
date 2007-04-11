From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: cel's patches under development
Date: Wed, 11 Apr 2007 08:41:20 +0200
Message-ID: <200704110841.21291.olaf.kirch@oracle.com>
References: <460852BB.4080503@oracle.com>
	<200704101722.13798.olaf.kirch@oracle.com>
	<1176233539.309.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbWY9-0003Tr-Tf
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 23:43:25 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbWYC-00008v-41
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 23:43:28 -0700
In-Reply-To: <1176233539.309.27.camel@heimdal.trondhjem.org>
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

On Tuesday 10 April 2007 21:32, Trond Myklebust wrote:
> I'm a bit wary of this. skbs are usually allocated from the ATOMIC pool
> which is a very limited resource: their lifetime really wants to be as
> short as possible. Won't this basically end up aggravating an already
> nasty situation w.r.t. our behaviour when under memory pressure?

I don't think so. We're talking about an additional delay caused by
moving the memcpy from the BH to some process (user or rpciod).
I agree that it would be a bad idea to keep these skbs around longer
than needed.

On the server side, the impact of this delay will probably be even
lower - skbs usually spend some time on the TCP socket's receive
queue anyway, and nfsd is pulling over the received packet
using recvmsg.

> Also, what about stuff like RDMA, which doesn't need this sort of
> mechanism in order to get things right?

But RDMA may benefit from the proposed interface for transport
specific receive buffers (rpc_data objects). How that buffer works is
entirely up to the transport. For TCP and UDP it's skb_lists, but for
RDMA it would probably be something very different.

Here's the mode of operation - XDR functions that expect to receive
data to a pagevec, such as READ, READLINK etc, call
xprt_rcvbuf_alloc(xprt, pages, pgbase, pglen) to allocate a
transport specific buffer object. Transports such as TCP or UDP
ignore the page vector, but the RDMA transport could use this
to do set up its buffers. From the implementation point of view,
it's probably not much different from extracting the pagevec
information from the xdr_buf receive buffer, but it looks cleaner
to me.

Likewise, it is possible to create transport-specific rpc_data
objects for sending data (and eg have RDMA do a DMA Send
for these). This would allow to get rid of the pagevec inside the
xdr_buf altogether.

> Finally, will we need to keep writing these very complex handlers for
> every new protocol that we want to add (e.g. IPv6, IPoIB, ...)?

No. TCP and UDP share the same skb_list handling code,
regardless of address family and link layer protocol. Adding
a transport such as DCCP will not need a new handler
either.

I believe the net result of this proposed restructuring will be
less complexity. Right now we have half a dozen or so
functions that walk through an xdr_buf (head, pagevec, tail)...
whereas with the proposed changes, you have the complexity
confined to one place.

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
