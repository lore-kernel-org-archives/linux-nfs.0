From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] - [7/15] - remove defconfig ptr comparisons to 0
	- fs/lockd
Date: Wed, 14 Nov 2007 13:40:47 +1100
Message-ID: <18234.24623.742782.328651@notabene.brown>
References: <1195005918.5163.93.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Joe Perches <joe@perches.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is8BQ-0007Dp-T4
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 18:40:52 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Is8BW-0007m7-B1
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 18:40:58 -0800
In-Reply-To: message from Joe Perches on Tuesday November 13
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

On Tuesday November 13, joe@perches.com wrote:
> Remove defconfig ptr comparison to 0
> 
> Remove sparse warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> ---
> 
> diff --git a/fs/lockd/svcshare.c b/fs/lockd/svcshare.c
> index 068886d..98548ad 100644
> --- a/fs/lockd/svcshare.c
> +++ b/fs/lockd/svcshare.c
> @@ -71,7 +71,7 @@ nlmsvc_unshare_file(struct nlm_host *host, struct nlm_file *file,
>  	struct nlm_share	*share, **shpp;
>  	struct xdr_netobj	*oh = &argp->lock.oh;
>  
> -	for (shpp = &file->f_shares; (share = *shpp) != 0; shpp = &share->s_next) {
> +	for (shpp = &file->f_shares; (share = *shpp); shpp = &share->s_next) {
>  		if (share->s_host == host && nlm_cmp_owner(share, oh)) {
>  			*shpp = share->s_next;
>  			kfree(share);
> 

I particularly disagree with this change as it now looked like it
could be an '==' comparison that was mistyped.  Making it 
        ....; (share = *shpp) != NULL; ....

makes the intent clear.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
