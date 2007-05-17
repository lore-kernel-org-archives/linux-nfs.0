From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 6/14] knfsd: add svc_sock_is_connection
Date: Thu, 17 May 2007 20:43:20 +1000
Message-ID: <17996.12744.227505.55367@notabene.brown>
References: <20070516192340.GL9626@sgi.com>
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
	id 1HodSD-0004J6-CS
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:43:29 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HodSE-00066m-UN
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 03:43:32 -0700
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
> +static inline int svc_sock_is_connection(struct svc_sock *svsk)
> +{
> +	return (test_bit(SK_TEMP, &svsk->sk_flags));
> +}

You seem to do a lot of this:  Pulling a simple bit operation out into
an inline function.
I must confess that I am not a big fan of this.  It makes the code
harder to read.  I keep running in to that sort of thing in the block
layer and buffer code, and it just slows me down: I go hunting to find
out what a function really does, and it turns out to be a simple
bit-op.

In this case, it adds some documentation (it isn't obvious that
testing SK_TEMP is the same as testing if the connection has a stable
remote endpoint), but a comment could fix that.

So I would rather simple change:
> -	if (svsk->sk_sock->type == SOCK_STREAM &&
to
> +	if (test_bit(SK_TEMP, &scsk->sk_flags) && /* is a tcp connection */

or similar.

Ditto the set/clear/test of  SK_CONN, SK_DATA, SK_CLOSE, unless you
have a very good reason.

The svc_sock_get, svc_sock_put I can live with as it is a very widely
used abstraction.  But not the bit ops.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
