From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] RPC: add wrapper for svc_reserve to account
	for	checksum
Date: Wed, 2 May 2007 07:54:57 +1000
Message-ID: <17975.46897.298001.690089@notabene.brown>
References: <20070421131523.GA18100@dantu.rdu.redhat.com>
	<17974.41587.666167.650575@notabene.brown>
	<20070501170123.GB15222@salusa.poochiereds.net>
	<20070501171121.GC15222@salusa.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	akpm@linux-foundation.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hj0Jo-0006XC-PQ
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 14:55:34 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hj0Jq-0000Z0-9v
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 14:55:34 -0700
In-Reply-To: message from Jeff Layton on Tuesday May 1
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

On Tuesday May 1, jlayton@redhat.com wrote:
> 
> Resending patch with a proper signed-off-by line. Also cc'ing Andrew:

Thanks, but it isn't much good to Andrew without a changelog entry,
though probably it should just go in as
  rpc--add-wrapper-for-svc_reserve-to-account-for-checksum-fix

Acked-by: NeilBrown <neilb@suse.de>

(If it doesn't appear in the next -mm, I'll send it all nicely
formated and changeloged).

NeilBrown

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 9114f11..ed7cbf1 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -399,10 +399,9 @@ char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
>  /*
>   * When we want to reduce the size of the reserved space in the response
>   * buffer, we need to take into account the size of any checksum data that
> - * may be at the end of the packet. For now, just use a hardcoded value
> - * for each possible authflavor. This will need to be updated when new
> - * encryption types or algorithms are added, or we'll have to come up with
> - * a way to reasonably calculate this on the fly (maybe via a new auth_op).
> + * may be at the end of the packet. This is difficult to determine exactly
> + * for all cases without actually generating the checksum, so we just use a
> + * static value.
>   */
>  static inline void 
>  svc_reserve_auth(struct svc_rqst *rqstp, int space)
> @@ -411,7 +410,7 @@ svc_reserve_auth(struct svc_rqst *rqstp, int space)
>  
>  	switch(rqstp->rq_authop->flavour) {
>  		case RPC_AUTH_GSS:
> -			added_space = 56; /* determined empirically */
> +			added_space = RPC_MAX_AUTH_SIZE;
>  	}
>  	return svc_reserve(rqstp, space + added_space);
>  }

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
