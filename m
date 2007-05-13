From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfsd: fix horrible indentation in nfsd_setattr
Date: Sun, 13 May 2007 21:44:07 +0100
Message-ID: <20070513204407.GC13563@infradead.org>
References: <20070307152625.GA29633@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnKvJ-0003Vp-35
	for nfs@lists.sourceforge.net; Sun, 13 May 2007 13:44:09 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HnKvK-0002z5-EU
	for nfs@lists.sourceforge.net; Sun, 13 May 2007 13:44:12 -0700
Received: from hch by pentafluge.infradead.org with local (Exim 4.63 #1 (Red
	Hat Linux)) id 1HnKvH-0003YO-Px
	for nfs@lists.sourceforge.net; Sun, 13 May 2007 21:44:07 +0100
In-Reply-To: <20070307152625.GA29633@infradead.org>
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

On Wed, Mar 07, 2007 at 03:26:25PM +0000, Christoph Hellwig wrote:
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

ping?

> 
> Index: linux-2.6/fs/nfsd/vfs.c
> ===================================================================
> --- linux-2.6.orig/fs/nfsd/vfs.c	2007-03-06 17:43:28.000000000 +0100
> +++ linux-2.6/fs/nfsd/vfs.c	2007-03-06 17:45:48.000000000 +0100
> @@ -277,7 +277,8 @@
>  	if (!iap->ia_valid)
>  		goto out;
>  
> -	/* NFSv2 does not differentiate between "set-[ac]time-to-now"
> +	/*
> +	 * NFSv2 does not differentiate between "set-[ac]time-to-now"
>  	 * which only requires access, and "set-[ac]time-to-X" which
>  	 * requires ownership.
>  	 * So if it looks like it might be "set both to the same time which
> @@ -290,25 +291,33 @@
>  	 */
>  #define BOTH_TIME_SET (ATTR_ATIME_SET | ATTR_MTIME_SET)
>  #define	MAX_TOUCH_TIME_ERROR (30*60)
> -	if ((iap->ia_valid & BOTH_TIME_SET) == BOTH_TIME_SET
> -	    && iap->ia_mtime.tv_sec == iap->ia_atime.tv_sec
> -	    ) {
> -	    /* Looks probable.  Now just make sure time is in the right ballpark.
> -	     * Solaris, at least, doesn't seem to care what the time request is.
> -	     * We require it be within 30 minutes of now.
> -	     */
> -	    time_t delta = iap->ia_atime.tv_sec - get_seconds();
> -	    if (delta<0) delta = -delta;
> -	    if (delta < MAX_TOUCH_TIME_ERROR &&
> -		inode_change_ok(inode, iap) != 0) {
> -		/* turn off ATTR_[AM]TIME_SET but leave ATTR_[AM]TIME
> -		 * this will cause notify_change to set these times to "now"
> +	if ((iap->ia_valid & BOTH_TIME_SET) == BOTH_TIME_SET &&
> +	    iap->ia_mtime.tv_sec == iap->ia_atime.tv_sec) {
> +	    	/*
> +		 * Looks probable.
> +		 *
> +		 * Now just make sure time is in the right ballpark.
> +		 * Solaris, at least, doesn't seem to care what the time
> +		 * request is.  We require it be within 30 minutes of now.
>  		 */
> -		iap->ia_valid &= ~BOTH_TIME_SET;
> -	    }
> +		time_t delta = iap->ia_atime.tv_sec - get_seconds();
> +		if (delta < 0)
> +			delta = -delta;
> +		if (delta < MAX_TOUCH_TIME_ERROR &&
> +		    inode_change_ok(inode, iap) != 0) {
> +		    	/*
> +			 * Turn off ATTR_[AM]TIME_SET but leave ATTR_[AM]TIME.
> +			 * This will cause notify_change to set these times
> +			 * to "now"
> +			 */
> +			iap->ia_valid &= ~BOTH_TIME_SET;
> +		}
>  	}
>  	    
> -	/* The size case is special. It changes the file as well as the attributes.  */
> +	/*
> +	 * The size case is special.
> +	 * It changes the file as well as the attributes.
> +	 */
>  	if (iap->ia_valid & ATTR_SIZE) {
>  		if (iap->ia_size < inode->i_size) {
>  			err = nfsd_permission(fhp->fh_export, dentry, MAY_TRUNC|MAY_OWNER_OVERRIDE);
> 
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys-and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
---end quoted text---

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
