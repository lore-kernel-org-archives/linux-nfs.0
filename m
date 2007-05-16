From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 2/14] knfsd: delete per transport
Date: Wed, 16 May 2007 16:51:23 -0400
Message-ID: <20070516205123.GB18927@fieldses.org>
References: <20070516191951.GH9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoQT4-0000b3-HU
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 13:51:44 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HoQT5-0002UW-Sp
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 13:51:33 -0700
In-Reply-To: <20070516191951.GH9626@sgi.com>
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

Trivial comments, since I couldn't find any real problems:

On Thu, May 17, 2007 at 05:19:51AM +1000, Greg Banks wrote:
> @@ -886,7 +883,9 @@ svc_udp_sendto(struct svc_rqst *rqstp)
>  static const struct svc_sock_ops svc_udp_ops = {
>  	.sko_name = "udp",
>  	.sko_recvfrom = svc_udp_recvfrom,
> -	.sko_sendto = svc_udp_sendto
> +	.sko_sendto = svc_udp_sendto,

Any objection to always just including a trailing comma and saving a
little noise in each diff?  That seems to be common practice elsewhere.

> +static void
> +svc_tcpip_free(struct svc_sock *svsk)
> +{
> +	dprintk("svc: svc_sock_free(%p)\n", svsk);

We lived without these dprintk's before; do we need them now?

> --- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-16 23:50:21.637425405 +1000
> +++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 00:12:50.074342601 +1000
> @@ -15,6 +15,18 @@ struct svc_sock_ops {
>  	const char		*sko_name;
>  	int			(*sko_recvfrom)(struct svc_rqst *rqstp);
>  	int			(*sko_sendto)(struct svc_rqst *rqstp);
> +	/*
> +	 * Detach the svc_sock from it's socket, so that the

s/it's/its/

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
