From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,
	PATCH 23/33] svc: Move the authinfo cache to svc_xprt.
Date: Fri, 28 Sep 2007 14:30:02 +1000
Message-ID: <18172.33610.417174.67852@notabene.brown>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050222.12677.48478.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ib7UP-0006SG-6q
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 21:30:09 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ib7UU-0006P7-0h
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 21:30:14 -0700
In-Reply-To: message from Tom Tucker on Thursday September 27
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

On Thursday September 27, tom@opengridcomputing.com wrote:
>  
>  	/* Initialize the socket */
>  	if (sock->type == SOCK_DGRAM) {
>  		svc_xprt_init(&svc_udp_class, &svsk->sk_xprt, serv);
>  		svc_udp_init(svsk);
> +		clear_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
>  	} else {
>  		svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt, serv);
>  		svc_tcp_init(svsk);
> +		set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
>  	}
>  

Why don't these clear_bit/set_bit calls go inside svc_{udp,tcp}_init?
Further, why aren't the svc_xprt_init calling inside there too?


NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
