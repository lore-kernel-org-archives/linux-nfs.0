From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/2] knfsd: clear both setuid and setgid whenever a
	chown is done
Date: Thu, 17 Apr 2008 17:47:48 -0400
Message-ID: <20080417214748.GJ9912@fieldses.org>
References: <1208377727-22834-1-git-send-email-jlayton@redhat.com>
	<1208377727-22834-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1208377727-22834-2-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the extra explanation--I've applied both.

--b.

On Wed, Apr 16, 2008 at 04:28:47PM -0400, Jeff Layton wrote:
> Currently, knfsd only clears the setuid bit if the owner of a file is
> changed on a SETATTR call, and only clears the setgid bit if the group
> is changed. POSIX says this in the spec for chown():
> 
>     "If the specified file is a regular file, one or more of the
>      S_IXUSR, S_IXGRP, or S_IXOTH bits of the file mode are set, and the
>      process does not have appropriate privileges, the set-user-ID
>      (S_ISUID) and set-group-ID (S_ISGID) bits of the file mode shall
>      be cleared upon successful return from chown()."
> 
> If I'm reading this correctly, then knfsd is doing this wrong. It should
> be clearing both the setuid and setgid bit on any SETATTR that changes
> the uid or gid. This wasn't really as noticable before, but now that the
> ATTR_KILL_S*ID bits are a no-op for the NFS client, it's more evident.
> 
> This patch corrects the nfsd_setattr logic so that this occurs. It also
> does a bit of cleanup to the function.
> 
> There is also one small behavioral change. If a SETATTR call comes in
> that changes the uid/gid and the mode, then we now only clear the setgid
> bit if the group execute bit isn't set. The setgid bit without a group
> execute bit signifies mandatory locking and we likely don't want to
> clear the bit in that case. Since there is no call in POSIX that should
> generate a SETATTR call like this, then this should rarely happen, but
> it's worth noting.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/vfs.c |   27 ++++++++++++++-------------
>  1 files changed, 14 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index dd4dcb4..f092b53 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -359,24 +359,25 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  		DQUOT_INIT(inode);
>  	}
>  
> +	/* sanitize the mode change */
>  	if (iap->ia_valid & ATTR_MODE) {
>  		iap->ia_mode &= S_IALLUGO;
>  		iap->ia_mode |= (inode->i_mode & ~S_IALLUGO);
> -		/* if changing uid/gid revoke setuid/setgid in mode */
> -		if ((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid) {
> -			iap->ia_valid |= ATTR_KILL_PRIV;
> +	}
> +
> +	/* Revoke setuid/setgid on chown */
> +	if (((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid) ||
> +	    ((iap->ia_valid & ATTR_GID) && iap->ia_gid != inode->i_gid)) {
> +		iap->ia_valid |= ATTR_KILL_PRIV;
> +		if (iap->ia_valid & ATTR_MODE) {
> +			/* we're setting mode too, just clear the s*id bits */
>  			iap->ia_mode &= ~S_ISUID;
> +			if (iap->ia_mode & S_IXGRP)
> +				iap->ia_mode &= ~S_ISGID;
> +		} else {
> +			/* set ATTR_KILL_* bits and let VFS handle it */
> +			iap->ia_valid |= (ATTR_KILL_SUID | ATTR_KILL_SGID);
>  		}
> -		if ((iap->ia_valid & ATTR_GID) && iap->ia_gid != inode->i_gid)
> -			iap->ia_mode &= ~S_ISGID;
> -	} else {
> -		/*
> -		 * Revoke setuid/setgid bit on chown/chgrp
> -		 */
> -		if ((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid)
> -			iap->ia_valid |= ATTR_KILL_SUID | ATTR_KILL_PRIV;
> -		if ((iap->ia_valid & ATTR_GID) && iap->ia_gid != inode->i_gid)
> -			iap->ia_valid |= ATTR_KILL_SGID;
>  	}
>  
>  	/* Change the attributes. */
> -- 
> 1.5.3.6
> 
