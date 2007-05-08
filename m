From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] introduce version field to struct nfs_clone_mount
Date: Mon, 07 May 2007 20:20:24 -0400
Message-ID: <1178583624.6158.107.camel@heimdal.trondhjem.org>
References: <1178560513.3898.32.camel@dhcp59-235.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: sds@tycho.nsa.gov, nfs@lists.sourceforge.net,
	selinux@tycho.nsa.gov
To: Eric Paris <eparis@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlDRO-0004np-T7
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 17:20:30 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/phbBThnwy8bLIzePpcd7Fg/bd1E+qqNo=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HlDRR-0001kC-1M
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 17:20:33 -0700
In-Reply-To: <1178560513.3898.32.camel@dhcp59-235.rdu.redhat.com>
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

On Mon, 2007-05-07 at 13:55 -0400, Eric Paris wrote:
> When selinux attempts to do its part of mounting a new FS it checks the
> mount data for selinux context information.  For most FS's this is a
> text string but for NFS this is a data blob (struct nfs_mount_data)
> Version 6 and later of this struct have a context field which selinux
> can use to pass context information from userspace to where it is used
> by selinux (security/selinux/hooks.c:try_context_mount())
> 
> The problem here is that we have found that exports with the 'nohide'
> option actually get mounted from fs/nfs/namespace.c:nfs_do_submount()
> which uses a struct nfs_clone_mount for its data.  This gets passed down
> into the selinux code 
> 
> nfs_do_submount()
>  nfs_do_clone_mount()
>   vfs_kern_mount()
>    security_sb_kern_mount()
>     selinux_sb_kern_mount()
>      superblock_doinit()
>       try_context_mount()
> 
> which finds that the fs being mounted is nfs based on:
> 
> strcmp(sb->s_type->name, "nfs")
> 
> The code in try_context_mount then casts the data to a struct
> nfs_mount_data.  Notice I just said the code cast a nfs_clone_mount to a
> nfs_mount_data.  Next it checks the version to make sure it should have
> the context field.  If so it uses the value in the context field if not
> it goes on.  The problem comes that the first entry in the
> nfs_mount_data is the version but the first entry in the nfs_clone_mount
> is a pointer.  Since the pointer is always bigger than the version we
> need we then try to dereference ->context which is outside of the data
> blob.  Since nfs_clone_data is smaller in size than nfs_mount_data we
> are just getting some stuff off of the stack.  If that data happens to
> be 0 (has been that way on all of my x86ish systems) everything works
> just fine.  If that data is not 0 the selinux code gets angry and
> refuses to mount the FS (which happens for me on other arches).
> 
> I could only think of 2 ways to solve this issue given the information
> which gets passed into the LSM hook from vfs_kern_mount.  One way would
> be to change the 'name' on the superblock when it comes from one of
> these non-standard code paths.  The other way was to simply add a new
> version field to the nfs_clone_mount structure that would line up with
> the version in nfs_mount_data.  That way the selinux code could do the
> cast between the two data types and still be able to tell when it had
> something it could use and when it couldn't.
> 
> I tested this patch on a number of arches and everything seems to be
> working happily.  Although I admit that the only code path I know how to
> exercise is through nfs_do_submount and I don't have any idea how to
> exercise the nfs_follow_referal code path or even exactly what
> implications referals have on this issue today.
> 
> -Eric
> 
> --- linux-2.6.21.x86_64/fs/nfs/internal.h.pre.version	2007-05-03 17:13:33.000000000 -0400
> +++ linux-2.6.21.x86_64/fs/nfs/internal.h	2007-05-03 17:15:36.000000000 -0400
> @@ -17,6 +17,12 @@ struct nfs4_mount_data;
>  #define NFS_MAX_READAHEAD	(RPC_DEF_SLOT_TABLE - 1)
>  
>  struct nfs_clone_mount {
> +	/* 
> +	 * This flag lines up bit wise with the version in nfs_mount_data and 
> +	 * will always be set to -1 to indicate this is an nfs_clone_mount 
> +	 * struct
> +	 */
> +	int version;
>  	const struct super_block *sb;
>  	const struct dentry *dentry;
>  	struct nfs_fh *fh;
> --- linux-2.6.21.x86_64/fs/nfs/namespace.c.pre.version	2007-05-03 17:16:01.000000000 -0400
> +++ linux-2.6.21.x86_64/fs/nfs/namespace.c	2007-05-03 17:16:13.000000000 -0400
> @@ -218,6 +218,7 @@ static struct vfsmount *nfs_do_submount(
>  					struct nfs_fattr *fattr)
>  {
>  	struct nfs_clone_mount mountdata = {
> +		.version = -1,
>  		.sb = mnt_parent->mnt_sb,
>  		.dentry = dentry,
>  		.fh = fh,
> --- linux-2.6.21.x86_64/fs/nfs/nfs4namespace.c.pre.version	2007-05-03 17:16:25.000000000 -0400
> +++ linux-2.6.21.x86_64/fs/nfs/nfs4namespace.c	2007-05-03 17:16:35.000000000 -0400
> @@ -126,6 +126,7 @@ static struct vfsmount *nfs_follow_refer
>  {
>  	struct vfsmount *mnt = ERR_PTR(-ENOENT);
>  	struct nfs_clone_mount mountdata = {
> +		.version = -1,
>  		.sb = mnt_parent->mnt_sb,
>  		.dentry = dentry,
>  		.authflavor = NFS_SB(mnt_parent->mnt_sb)->client->cl_auth->au_flavor,
> 

Eeewwwww... You are telling me that the secinfo stuff is trying to read
the NFS mount data binary information? WTF for?

Vetoed....

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
