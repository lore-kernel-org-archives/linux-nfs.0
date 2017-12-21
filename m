Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:33354 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752471AbdLUPuX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Dec 2017 10:50:23 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH/RFC] NFS: add nostatflush mount option.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87k1xgkct1.fsf@notabene.neil.brown.name>
Date: Thu, 21 Dec 2017 10:39:27 -0500
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
Message-Id: <4B4DA4D4-8068-4C10-92BE-F03632522C75@oracle.com>
References: <87k1xgkct1.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-


> On Dec 20, 2017, at 9:57 PM, NeilBrown <neilb@suse.com> wrote:
>=20
>=20
> When an i_op->getattr() call is made on an NFS file
> (typically from a 'stat' family system call), NFS
> will first flush any dirty data to the server.
>=20
> This ensures that the mtime reported is correct and stable,
> but has a performance penalty.  'stat' is normally thought
> to be a quick operation, and imposing this cost can be
> surprising.

To be clear, this behavior is a POSIX requirement.


> I have seen problems when one process is writing a large
> file and another process performs "ls -l" on the containing
> directory and is blocked for as long as it take to flush
> all the dirty data to the server, which can be minutes.

Yes, a well-known annoyance that cannot be addressed
even with a write delegation.


> I have also seen a legacy application which frequently calls
> "fstat" on a file that it is writing to.  On a local
> filesystem (and in the Solaris implementation of NFS) this
> fstat call is cheap.  On Linux/NFS, the causes a noticeable
> decrease in throughput.

If the preceding write is small, Linux could be using
a FILE_SYNC write, but Solaris could be using UNSTABLE.


> The only circumstances where an application calling 'stat()'
> might get an mtime which is not stable are times when some
> other process is writing to the file and the two processes
> are not using locking to ensure consistency, or when the one
> process is both writing and stating.  In neither of these
> cases is it reasonable to expect the mtime to be stable.

I'm not convinced this is a strong enough rationale
for claiming it is safe to disable the existing
behavior.

You've explained cases where the new behavior is
reasonable, but do you have any examples where the
new behavior would be a problem? There must be a
reason why POSIX explicitly requires an up-to-date
mtime.

What guidance would nfs(5) give on when it is safe
to specify the new mount option?


> In the most common cases where mtime is important
> (e.g. make), no other process has the file open, so there
> will be no dirty data and the mtime will be stable.

Isn't it also the case that make is a multi-process
workload where one process modifies a file, then
closes it (which triggers a flush), and then another
process stats the file? The new mount option does
not change the behavior of close(2), does it?


> Rather than unilaterally changing this behavior of 'stat',
> this patch adds a "nosyncflush" mount option to allow
> sysadmins to have applications which are hurt by the current
> behavior to disable it.

IMO a mount option is at the wrong granularity. A
mount point will be shared between applications that
can tolerate the non-POSIX behavior and those that
cannot, for instance.

I would rather see us address the underlying cause
of the delay, which is that the GETATTR gets starved
by an ongoing stream of WRITE requests. You could:

- Make active writers wait for the GETATTR so the
GETATTR is not starved

- Start flushing dirty pages earlier so there is
less to flush when a stat(2) is done

- Ensure that GETATTR is not also waiting for a
COMMIT

Or maybe there's some other problem?

I recall nfs_getattr used to grab i_mutex to hold
up active writers. But i_mutex is gone now. Is
there some other mechanism that can block writers
while the client flushes the file and handles the
GETATTR request?


> Note that this option should probably *not* be used together
> with "nocto".  In that case, mtime could be unstable even
> when no process has the file open.
>=20
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> fs/nfs/inode.c                 |  3 ++-
> fs/nfs/super.c                 | 10 ++++++++++
> include/uapi/linux/nfs_mount.h |  6 ++++--
> 3 files changed, 16 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index b992d2382ffa..16629a34dd62 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -740,7 +740,8 @@ int nfs_getattr(const struct path *path, struct =
kstat *stat,
>=20
> 	trace_nfs_getattr_enter(inode);
> 	/* Flush out writes to the server in order to update c/mtime.  =
*/
> -	if (S_ISREG(inode->i_mode)) {
> +	if (S_ISREG(inode->i_mode) &&
> +	    !(NFS_SERVER(inode)->flags & NFS_MOUNT_NOSTATFLUSH)) {
> 		err =3D filemap_write_and_wait(inode->i_mapping);
> 		if (err)
> 			goto out;
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 29bacdc56f6a..2351c0be98f5 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -90,6 +90,7 @@ enum {
> 	Opt_resvport, Opt_noresvport,
> 	Opt_fscache, Opt_nofscache,
> 	Opt_migration, Opt_nomigration,
> +	Opt_statflush, Opt_nostatflush,
>=20
> 	/* Mount options that take integer arguments */
> 	Opt_port,
> @@ -151,6 +152,8 @@ static const match_table_t nfs_mount_option_tokens =
=3D {
> 	{ Opt_nofscache, "nofsc" },
> 	{ Opt_migration, "migration" },
> 	{ Opt_nomigration, "nomigration" },
> +	{ Opt_statflush, "statflush" },
> +	{ Opt_nostatflush, "nostatflush" },
>=20
> 	{ Opt_port, "port=3D%s" },
> 	{ Opt_rsize, "rsize=3D%s" },
> @@ -637,6 +640,7 @@ static void nfs_show_mount_options(struct seq_file =
*m, struct nfs_server *nfss,
> 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
> 		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
> 		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
> +		{ NFS_MOUNT_NOSTATFLUSH, ",nostatflush", "" },
> 		{ 0, NULL, NULL }
> 	};
> 	const struct proc_nfs_info *nfs_infop;
> @@ -1334,6 +1338,12 @@ static int nfs_parse_mount_options(char *raw,
> 		case Opt_nomigration:
> 			mnt->options &=3D ~NFS_OPTION_MIGRATION;
> 			break;
> +		case Opt_statflush:
> +			mnt->flags &=3D ~NFS_MOUNT_NOSTATFLUSH;
> +			break;
> +		case Opt_nostatflush:
> +			mnt->flags |=3D NFS_MOUNT_NOSTATFLUSH;
> +			break;
>=20
> 		/*
> 		 * options that take numeric values
> diff --git a/include/uapi/linux/nfs_mount.h =
b/include/uapi/linux/nfs_mount.h
> index e44e00616ab5..d7c6f809d25d 100644
> --- a/include/uapi/linux/nfs_mount.h
> +++ b/include/uapi/linux/nfs_mount.h
> @@ -72,7 +72,9 @@ struct nfs_mount_data {
> #define NFS_MOUNT_NORESVPORT		0x40000
> #define NFS_MOUNT_LEGACY_INTERFACE	0x80000
>=20
> -#define NFS_MOUNT_LOCAL_FLOCK	0x100000
> -#define NFS_MOUNT_LOCAL_FCNTL	0x200000
> +#define NFS_MOUNT_LOCAL_FLOCK		0x100000
> +#define NFS_MOUNT_LOCAL_FCNTL		0x200000
> +
> +#define NFS_MOUNT_NOSTATFLUSH		0x400000
>=20
> #endif
> --=20
> 2.14.0.rc0.dirty
>=20

--
Chuck Lever



