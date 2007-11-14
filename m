From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] - [9/15] - remove defconfig ptr comparisons to 0
	- fs/nfsd
Date: Wed, 14 Nov 2007 13:38:05 +1100
Message-ID: <18234.24461.192099.360005@notabene.brown>
References: <1195005925.5163.95.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is88p-00071g-Ak
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 18:38:11 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Is88t-0005nB-Uc
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 18:38:17 -0800
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
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index d019918..07b38cf 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -987,7 +987,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>  	 * flushing the data to disk is handled separately below.
>  	 */
>  
> -	if (file->f_op->fsync == 0) {/* COMMIT3 cannot work */
> +	if (!file->f_op->fsync) {/* COMMIT3 cannot work */
>  	       stable = 2;
>  	       *stablep = 2; /* FILE_SYNC */
>  	}
> 

Personally, I would much rather these were changed to "== NULL".
Different people have different preferences on whether to use
    ! foo
or
    foo == NULL

and the person who wrote that code is presumably showing a preference
for the later.  Changing it from "== 0" to "== NULL" is clearly a
valuable improvement.  Changing from "== 0" to "! " is a stylistic
change that should not be made lightly.

I personally often use and prefer the explicit comparison to NULL.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
