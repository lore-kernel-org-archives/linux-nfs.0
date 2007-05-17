From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 8/14] knfsd: centralise SK_CLOSE handling
Date: Thu, 17 May 2007 20:59:18 +1000
Message-ID: <17996.13702.484468.777723@notabene.brown>
References: <20070516192509.GN9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hodhe-00064V-1I
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:59:26 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hodhg-0001rT-Mk
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:59:29 -0700
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
> 
> Centralise the handling of the SK_CLOSE bit to that future
> sunrpc server transport implementations will be easier to
> write correctly.  The bit should now not be manipulated
> directly, inline exist to wrap that.  Also, the sko_recvfrom
> method does not need to check for SK_CLOSE anymore, that's
> handled in core code.
...
>  
>  		if (svsk) {
> -			svc_sock_enqueue(svsk);
> +			/*
> +			 * We're always called in nfsd context so we
> +			 * don't have to muck around with SK_CLOSE.
> +			 */
> +			svc_delete_socket(svsk);
>  			svc_sock_put(svsk);
>  		}

I'm not convinced that this is right.  
svc_delete_socket has a comment:
	/*
	 * We used to delete the svc_sock from whichever list
	 * it's sk_ready node was on, but we don't actually
	 * need to.  This is because the only time we're called
	 * while still attached to a queue, the queue itself
	 * is about to be destroyed (in svc_destroy).
	 */
and I think this change invalidate the premise of that comment.
I would much rather this was svc_sock_delete_bh.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
