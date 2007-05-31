From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] locks: share more common lease code
Date: Thu, 31 May 2007 17:51:37 -0400
Message-ID: <1180648297.7084.7.camel@heimdal.trondhjem.org>
References: <1180647624483-git-send-email-bfields@fieldses.org>
	<11806476252240-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	David Teigland <teigland@redhat.com>,
	Marc Eshel <eshel@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HtsYi-0001dU-R6
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 14:51:52 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18O3kBPdCvgacydk8yODLSdtc/vNW43V08=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HtsYk-0000EA-DJ
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 14:51:56 -0700
In-Reply-To: <11806476252240-git-send-email-bfields@fieldses.org>
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

On Thu, 2007-05-31 at 17:40 -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> Share more code between setlease (used by nfsd) and fcntl.
> 
> Also some minor cleanup.
> 
> Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
> ---
>  fs/locks.c |   14 +++-----------
>  1 files changed, 3 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 431a8b8..3f366e1 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1469,14 +1469,6 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
>  	struct inode *inode = dentry->d_inode;
>  	int error;
>  
> -	if ((current->fsuid != inode->i_uid) && !capable(CAP_LEASE))
> -		return -EACCES;
> -	if (!S_ISREG(inode->i_mode))
> -		return -EINVAL;
> -	error = security_file_lock(filp, arg);
> -	if (error)
> -		return error;
> -
>  	locks_init_lock(&fl);
>  	error = lease_init(filp, arg, &fl);
>  	if (error)
> @@ -1484,15 +1476,15 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
>  
>  	lock_kernel();
>  
> -	error = __setlease(filp, arg, &flp);
> +	error = setlease(filp, arg, &flp);
>  	if (error || arg == F_UNLCK)
>  		goto out_unlock;
>  
>  	error = fasync_helper(fd, filp, 1, &flp->fl_fasync);
>  	if (error < 0) {
> -		/* remove lease just inserted by __setlease */
> +		/* remove lease just inserted by setlease */
>  		flp->fl_type = F_UNLCK | F_INPROGRESS;
> -		flp->fl_break_time = jiffies- 10;
> +		flp->fl_break_time = jiffies - 10;
>  		time_out_leases(inode);
>  		goto out_unlock;
>  	}

Why not move the security checks from setlease() into __setlease()? That
way you can continue to avoid the calls to (re)take the BKL, which are
redundant as far as fcntl_setlease() is concerned.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
