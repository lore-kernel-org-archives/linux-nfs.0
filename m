From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 3/3] NFS: Ensure we support selinux xattrs
Date: Wed, 24 Jan 2007 15:08:08 -0500
Message-ID: <1169669288.15390.155.camel@moss-spartans.epoch.ncsc.mil>
References: <20070124195307.21259.64156.stgit@lade.trondhjem.org>
	<20070124195457.21259.53047.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@osdl.org, Jim Meyering <meyering@redhat.com>,
	linux-kernel@vger.kernel.org, Eric Paris <eparis@redhat.com>,
	James Morris <jmorris@namei.org>, torvalds@osdl.org,
	nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9oSP-0006JQ-Rt
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:10:58 -0800
Received: from zombie.ncsc.mil ([144.51.88.131] helo=jazzdrum.ncsc.mil)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H9oSO-0002bD-Ha
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:10:59 -0800
In-Reply-To: <20070124195457.21259.53047.stgit@lade.trondhjem.org>
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

On Wed, 2007-01-24 at 11:54 -0800, Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Some programs (e.g. GNU "cp") are currently crashing because NFS
> allows you to inquire about SELinux security attributes (vfs_getxattr()
> automatically handles this), but returns -EOPNOTSUPP when they later
> attempt to set the SELinux security attributes.
> 
> The following patch just ensures that we pass the request to set security
> attributes on to the default SELinux handler.

That seems like a bug in cp, and it can happen under other circumstances
as well (mount with context= option).

I don't think you want to just set the incore inode security state on
the client side, as that won't be preserved.

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/nfs3acl.c  |   13 +++++++++++++
>  fs/nfs/nfs4proc.c |   14 ++++++++++++++
>  2 files changed, 27 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
> index 7322da4..5970e7b 100644
> --- a/fs/nfs/nfs3acl.c
> +++ b/fs/nfs/nfs3acl.c
> @@ -4,6 +4,9 @@ #include <linux/nfs3.h>
>  #include <linux/nfs_fs.h>
>  #include <linux/posix_acl_xattr.h>
>  #include <linux/nfsacl.h>
> +#include <linux/security.h>
> +#include <linux/xattr.h>
> +#include <linux/fsnotify.h>
>  
>  #define NFSDBG_FACILITY	NFSDBG_PROC
>  
> @@ -82,6 +85,16 @@ int nfs3_setxattr(struct dentry *dentry,
>  	struct posix_acl *acl;
>  	int type, error;
>  
> +	/* Selinux support */
> +	if (!strncmp(name, XATTR_SECURITY_PREFIX, XATTR_SECURITY_PREFIX_LEN)) {
> +		const char *suffix = name + XATTR_SECURITY_PREFIX_LEN;
> +		error = security_inode_setsecurity(inode, suffix, value,
> +				size, flags);
> +		if (!error)
> +			fsnotify_xattr(dentry);
> +		return error;
> +	}
> +
>  	if (strcmp(name, POSIX_ACL_XATTR_ACCESS) == 0)
>  		type = ACL_TYPE_ACCESS;
>  	else if (strcmp(name, POSIX_ACL_XATTR_DEFAULT) == 0)
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index b3fd29b..ac1082b 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -48,6 +48,9 @@ #include <linux/nfs_page.h>
>  #include <linux/smp_lock.h>
>  #include <linux/namei.h>
>  #include <linux/mount.h>
> +#include <linux/security.h>
> +#include <linux/xattr.h>
> +#include <linux/fsnotify.h>
>  
>  #include "nfs4_fs.h"
>  #include "delegation.h"
> @@ -3547,6 +3550,17 @@ int nfs4_setxattr(struct dentry *dentry,
>  {
>  	struct inode *inode = dentry->d_inode;
>  
> +	/* Selinux support */
> +	if (!strncmp(key, XATTR_SECURITY_PREFIX, XATTR_SECURITY_PREFIX_LEN)) {
> +		const char *suffix = key + XATTR_SECURITY_PREFIX_LEN;
> +		int error;
> +		error = security_inode_setsecurity(inode, suffix, buf,
> +				buflen, flags);
> +		if (!error)
> +			fsnotify_xattr(dentry);
> +		return error;
> +	}
> +
>  	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
>  		return -EOPNOTSUPP;
>  
-- 
Stephen Smalley
National Security Agency


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
