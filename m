From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC, PATCH 7/14] knfsd: export svc_sock_enqueue,
	svc_sock_received
Date: Thu, 17 May 2007 20:13:59 +1000
Message-ID: <17996.10983.101466.866944@notabene.brown>
References: <20070516192425.GM9626@sgi.com>
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
	id 1Hoczv-0000Xi-Gc
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:14:15 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hoczx-0006Io-2Q
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:14:18 -0700
In-Reply-To: message from Greg Banks on Thursday May 17
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

On Thursday May 17, gnb@sgi.com wrote:
> Index: linux/net/sunrpc/sunrpc_syms.c
> ===================================================================
> --- linux.orig/net/sunrpc/sunrpc_syms.c	2007-04-26 13:08:32.000000000 +1000
> +++ linux/net/sunrpc/sunrpc_syms.c	2007-05-17 02:09:47.762054713 +1000
> @@ -77,6 +77,8 @@ EXPORT_SYMBOL(svc_process);
>  EXPORT_SYMBOL(svc_recv);
>  EXPORT_SYMBOL(svc_wake_up);
>  EXPORT_SYMBOL(svc_makesock);
> +EXPORT_SYMBOL_GPL(svc_sock_enqueue);
> +EXPORT_SYMBOL_GPL(svc_sock_received);
>  EXPORT_SYMBOL(svc_reserve);
>  EXPORT_SYMBOL(svc_auth_register);
>  EXPORT_SYMBOL(auth_domain_lookup);

Can we please put new EXPORT_SYMBOLS near the function rather than in
this file?  And if anyone wants to move them all out, I'm fine with
that.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
