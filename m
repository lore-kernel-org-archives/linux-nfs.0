From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 1/3] VFS: make notify_change pass ATTR_KILL_S*ID
 to	setattr operations
Date: Thu, 30 Aug 2007 12:03:09 -0400
Message-ID: <46D6EA3D.4010003@redhat.com>
References: <200708301506.l7UF6c63002133@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, linux-cifs-client@lists.samba.org,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQn4H-0006hy-Om
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:40:29 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQn4L-0000m4-Vy
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:40:34 -0700
In-Reply-To: <200708301506.l7UF6c63002133@dantu.rdu.redhat.com>
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

Jeff Layton wrote:
> Make notify_change not clear the ATTR_KILL_S*ID bits in the ia_vaid that
> gets passed to the setattr inode operation. This allows the filesystems
> to reinterpret whether this mode change is simply intended to clear the
> setuid/setgid bits.
>
> This means that notify_change should never be called with both ATTR_MODE
> and either of the ATTR_KILL_S*ID bits set, since the filesystem would
> have no way to know what part of the mode change was intentional. If
> it is called this way, consider it a BUG().
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/attr.c |   22 ++++++++++++----------
>  1 files changed, 12 insertions(+), 10 deletions(-)
>
> diff --git a/fs/attr.c b/fs/attr.c
> index ae58bd3..f98d10c 100644
> --- a/fs/attr.c
> +++ b/fs/attr.c
> @@ -103,12 +103,11 @@ EXPORT_SYMBOL(inode_setattr);
>  int notify_change(struct dentry * dentry, struct iattr * attr)
>  {
>  	struct inode *inode = dentry->d_inode;
> -	mode_t mode;
> +	mode_t mode = inode->i_mode;
>  	int error;
>  	struct timespec now;
>  	unsigned int ia_valid = attr->ia_valid;
>  
> -	mode = inode->i_mode;
>  	now = current_fs_time(inode->i_sb);
>  
>  	attr->ia_ctime = now;
> @@ -125,18 +124,21 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
>  		if (error)
>  			return error;
>  	}
> +
> +	/*
> +	 * It's not valid to pass an iattr with both ATTR_MODE and
> +	 * ATTR_KILL_S*ID set.
> +	 */
> +	if (ia_valid & (ATTR_KILL_SUID|ATTR_KILL_SGID) && ia_valid & ATTR_MODE)
>   

If you would, please add some parentheses to show and make
explicit what the bindings are.  This is:

       if ((ia_valid & (ATTR_KILL_SUID | ATTR_KILL_SGID)) &&
           (ia_valid & ATTR_MODE))

Thanx...

       ps

> +		BUG();
> +
>  	if (ia_valid & ATTR_KILL_SUID) {
> -		attr->ia_valid &= ~ATTR_KILL_SUID;
>  		if (mode & S_ISUID) {
> -			if (!(ia_valid & ATTR_MODE)) {
> -				ia_valid = attr->ia_valid |= ATTR_MODE;
> -				attr->ia_mode = inode->i_mode;
> -			}
> -			attr->ia_mode &= ~S_ISUID;
> +			ia_valid = attr->ia_valid |= ATTR_MODE;
> +			attr->ia_mode = (inode->i_mode & ~S_ISUID);
>  		}
>  	}
>  	if (ia_valid & ATTR_KILL_SGID) {
> -		attr->ia_valid &= ~ ATTR_KILL_SGID;
>  		if ((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)) {
>  			if (!(ia_valid & ATTR_MODE)) {
>  				ia_valid = attr->ia_valid |= ATTR_MODE;
> @@ -145,7 +147,7 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
>  			attr->ia_mode &= ~S_ISGID;
>  		}
>  	}
> -	if (!attr->ia_valid)
> +	if (!(attr->ia_valid & ~(ATTR_KILL_SUID | ATTR_KILL_SGID)))
>  		return 0;
>  
>  	if (ia_valid & ATTR_SIZE)
>   


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
