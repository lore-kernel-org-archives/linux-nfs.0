From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: [PATCH 001 of 3] knfsd: Use recv_msg to get peer address
	for NFSD instead of code-copying
Date: Mon, 5 Mar 2007 19:53:23 +0100
Message-ID: <200703051953.24900.olaf.kirch@oracle.com>
References: <20070302151748.5226.patches@notabene> <1070302042825.5760@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOILN-00058N-Lk
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 10:55:34 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HOILO-0007mA-5e
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 10:55:35 -0800
In-Reply-To: <1070302042825.5760@suse.de>
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

On Friday 02 March 2007 05:28, NeilBrown wrote:
> The sunrpc server code needs to know the source and destination address
> for UDP packets so it can reply properly.
> It currently copies code out of the network stack to pick the pieces out
> of the skb.
> This is ugly and causes compile problems with the IPv6 stuff.

... and this IPv6 code could never have worked anyway:


>  	case AF_INET6: {
...
> -			rqstp->rq_addrlen = sizeof(struct sockaddr_in);
... this should have been sizeof(sockaddr_in6)...

> -			/* Remember which interface received this request */
> -			ipv6_addr_copy(&rqstp->rq_daddr.addr6,
> -							&skb->nh.ipv6h->saddr);
.... and this should have copied from daddr, not saddr.

But I find using recvmsg just for getting at the addresses
a little awkward too. And I think to be on the safe side, you
should check that you're really looking at a PKTINFO cmsg
rather than something else.

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
