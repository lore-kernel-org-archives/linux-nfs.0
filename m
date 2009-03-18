From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Inconsistent setattr behaviour
Date: Wed, 18 Mar 2009 17:39:17 -0400
Message-ID: <20090318213917.GD18894@fieldses.org>
References: <49A2CD2B.50607@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Sachin S. Prabhu" <sprabhu@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:34983 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643AbZCRVjT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 17:39:19 -0400
In-Reply-To: <49A2CD2B.50607@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 23, 2009 at 04:22:03PM +0000, Sachin S. Prabhu wrote:
> There is an inconsistency seen in the behaviour of nfs compared to other local
> filesystems on linux when changing owner or group of a directory. If the
> directory has SUID/SGID flags set, on changing owner or group on the directory,
> the flags are stripped off on nfs. These flags are maintained on other
> filesystems such as ext3.
> 
> To reproduce on a nfs share or local filesystem, run the following commands
> mkdir test; chmod +s+g test; chown user1 test; ls -ld test
> 
> On the nfs share, the flags are stripped and the output seen is
> drwxr-xr-x 2 user1 root 4096 Feb 23  2009 test
> 
> On other local filesystems(ex: ext3), the flags are not stripped and the output
> seen is
> drwsr-sr-x 2 user1 root 4096 Feb 23 13:57 test
> 
> chown_common() called from sys_chown() will only strip the flags if the inode is
> not a directory.
> static int chown_common(struct dentry * dentry, uid_t user, gid_t group)
> {
> ..
>         if (!S_ISDIR(inode->i_mode))
>                 newattrs.ia_valid |=
>                         ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_KILL_PRIV;
> ..
> }
> 
> See: http://www.opengroup.org/onlinepubs/7990989775/xsh/chown.html
> 
> "If the path argument refers to a regular file, the set-user-ID (S_ISUID) and
> set-group-ID (S_ISGID) bits of the file mode are cleared upon successful return
> from chown(), unless the call is made by a process with appropriate privileges,
> in which case it is implementation-dependent whether these bits are altered. If
> chown() is successfully invoked on a file that is not a regular file, these
> bits may be cleared. These bits are defined in <sys/stat.h>."
> 
> The behaviour as it stands does not appear to violate POSIX.  However the
> actions performed are inconsistent when comparing ext3 and nfs.

Makes sense, thanks!--applied for 2.6.30.--b.

> 
> Sachin Prabhu

> Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
> Acked-by: Jeff Layton <jlayton@redhat.com>
> --- linux-2.6.29-rc2/fs/nfsd/vfs.c.orig	2009-02-23 06:45:20.000000000 -0500
> +++ linux-2.6.29-rc2/fs/nfsd/vfs.c	2009-02-23 11:10:10.000000000 -0500
> @@ -366,8 +366,9 @@
>  	}
>  
>  	/* Revoke setuid/setgid on chown */
> -	if (((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid) ||
> -	    ((iap->ia_valid & ATTR_GID) && iap->ia_gid != inode->i_gid)) {
> +	if (!S_ISDIR(inode->i_mode) &&
> +	    (((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid) ||
> +	     ((iap->ia_valid & ATTR_GID) && iap->ia_gid != inode->i_gid))) {
>  		iap->ia_valid |= ATTR_KILL_PRIV;
>  		if (iap->ia_valid & ATTR_MODE) {
>  			/* we're setting mode too, just clear the s*id bits */

