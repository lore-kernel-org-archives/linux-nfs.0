From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 11/33] svc: Add xpo_accept transport function
Date: Fri, 28 Sep 2007 13:21:14 +1000
Message-ID: <18172.29482.366028.515043@notabene.brown>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050157.12677.92320.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ib6Po-0000EN-OH
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 20:21:20 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ib6Pt-0005Tx-HD
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 20:21:25 -0700
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
> @@ -1046,9 +1054,10 @@ static inline int svc_port_is_privileged
>  /*
>   * Accept a TCP connection
>   */
> -static void
> -svc_tcp_accept(struct svc_sock *svsk)
> +static struct svc_xprt *
> +svc_tcp_accept(struct svc_xprt *xprt)
>  {
> +	struct svc_sock *svsk = (struct svc_sock *)xprt;

This cast should use container_of

        struct svc_sock *svsk = container_of(xprt, struct svc_sock *, sk_xprt);

That makes it clearer what is happening.



NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
