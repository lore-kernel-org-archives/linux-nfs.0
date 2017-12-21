Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41435 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756660AbdLUC55 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Dec 2017 21:57:57 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Thu, 21 Dec 2017 13:57:46 +1100
Cc: lkml <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH/RFC] NFS: add nostatflush mount option.
Message-ID: <87k1xgkct1.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


When an i_op->getattr() call is made on an NFS file
(typically from a 'stat' family system call), NFS
will first flush any dirty data to the server.

This ensures that the mtime reported is correct and stable,
but has a performance penalty.  'stat' is normally thought
to be a quick operation, and imposing this cost can be
surprising.

I have seen problems when one process is writing a large
file and another process performs "ls -l" on the containing
directory and is blocked for as long as it take to flush
all the dirty data to the server, which can be minutes.

I have also seen a legacy application which frequently calls
"fstat" on a file that it is writing to.  On a local
filesystem (and in the Solaris implementation of NFS) this
fstat call is cheap.  On Linux/NFS, the causes a noticeable
decrease in throughput.

The only circumstances where an application calling 'stat()'
might get an mtime which is not stable are times when some
other process is writing to the file and the two processes
are not using locking to ensure consistency, or when the one
process is both writing and stating.  In neither of these
cases is it reasonable to expect the mtime to be stable.

In the most common cases where mtime is important
(e.g. make), no other process has the file open, so there
will be no dirty data and the mtime will be stable.

Rather than unilaterally changing this behavior of 'stat',
this patch adds a "nosyncflush" mount option to allow
sysadmins to have applications which are hurt by the current
behavior to disable it.

Note that this option should probably *not* be used together
with "nocto".  In that case, mtime could be unstable even
when no process has the file open.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/inode.c                 |  3 ++-
 fs/nfs/super.c                 | 10 ++++++++++
 include/uapi/linux/nfs_mount.h |  6 ++++--
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b992d2382ffa..16629a34dd62 100644
=2D-- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -740,7 +740,8 @@ int nfs_getattr(const struct path *path, struct kstat *=
stat,
=20
 	trace_nfs_getattr_enter(inode);
 	/* Flush out writes to the server in order to update c/mtime.  */
=2D	if (S_ISREG(inode->i_mode)) {
+	if (S_ISREG(inode->i_mode) &&
+	    !(NFS_SERVER(inode)->flags & NFS_MOUNT_NOSTATFLUSH)) {
 		err =3D filemap_write_and_wait(inode->i_mapping);
 		if (err)
 			goto out;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 29bacdc56f6a..2351c0be98f5 100644
=2D-- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -90,6 +90,7 @@ enum {
 	Opt_resvport, Opt_noresvport,
 	Opt_fscache, Opt_nofscache,
 	Opt_migration, Opt_nomigration,
+	Opt_statflush, Opt_nostatflush,
=20
 	/* Mount options that take integer arguments */
 	Opt_port,
@@ -151,6 +152,8 @@ static const match_table_t nfs_mount_option_tokens =3D {
 	{ Opt_nofscache, "nofsc" },
 	{ Opt_migration, "migration" },
 	{ Opt_nomigration, "nomigration" },
+	{ Opt_statflush, "statflush" },
+	{ Opt_nostatflush, "nostatflush" },
=20
 	{ Opt_port, "port=3D%s" },
 	{ Opt_rsize, "rsize=3D%s" },
@@ -637,6 +640,7 @@ static void nfs_show_mount_options(struct seq_file *m, =
struct nfs_server *nfss,
 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
 		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
 		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
+		{ NFS_MOUNT_NOSTATFLUSH, ",nostatflush", "" },
 		{ 0, NULL, NULL }
 	};
 	const struct proc_nfs_info *nfs_infop;
@@ -1334,6 +1338,12 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_nomigration:
 			mnt->options &=3D ~NFS_OPTION_MIGRATION;
 			break;
+		case Opt_statflush:
+			mnt->flags &=3D ~NFS_MOUNT_NOSTATFLUSH;
+			break;
+		case Opt_nostatflush:
+			mnt->flags |=3D NFS_MOUNT_NOSTATFLUSH;
+			break;
=20
 		/*
 		 * options that take numeric values
diff --git a/include/uapi/linux/nfs_mount.h b/include/uapi/linux/nfs_mount.h
index e44e00616ab5..d7c6f809d25d 100644
=2D-- a/include/uapi/linux/nfs_mount.h
+++ b/include/uapi/linux/nfs_mount.h
@@ -72,7 +72,9 @@ struct nfs_mount_data {
 #define NFS_MOUNT_NORESVPORT		0x40000
 #define NFS_MOUNT_LEGACY_INTERFACE	0x80000
=20
=2D#define NFS_MOUNT_LOCAL_FLOCK	0x100000
=2D#define NFS_MOUNT_LOCAL_FCNTL	0x200000
+#define NFS_MOUNT_LOCAL_FLOCK		0x100000
+#define NFS_MOUNT_LOCAL_FCNTL		0x200000
+
+#define NFS_MOUNT_NOSTATFLUSH		0x400000
=20
 #endif
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlo7IysACgkQOeye3VZi
gbmUvg/8CnSluhBBny4spSZy0Vh+Uf3AwLUOgr8mNyG5tW2eMzxBW1VSCx7Qr9TU
WrY6kOd4Dh5S6fH4zv1hqMHSyp01kpMipL/mbEW3LNiyMYKqpaJym1Xq1eaeZ54t
M70HdTpoeyaiKSprQcSybBuctFn4/pcZLZfVS+hXZnPTQ7TbSd1OD5hqhGFVzvp3
kPL1GMPVGincPrcsXI0+0+FoyB8mlBZxiA62wVxI81CdAetjGI+Sotb3ds6tFoSS
wR0P0FlDHZ/XR3YpC4lNvFiPnbxaGvy/DyJoXnyv3lzNmsYTtx/LZgrRczNz2lpM
7Qg3lhqe7G2ddPmViwHgnEycQCNPx++uoo+KwxJPLCOCQGGc/wpy8NXjb7fBHCYy
TgmmQEWgySXjPemgXXmpvRjGRxCLO2iKwBIL2PpJqJ6mzbubaFC8h8AzDko6TbNO
UtUfBXB5b9POJ/mfz8auMefJNkhTdbA7rBjtkG90abruaGQAwCg/9gxspm6XTtfI
jwnpZ2rgfWbDJaEJhNB1LbhcYgjVSO/7mTTfj3s5ONnV4BCLnyO2Nwd9fcSzL0w5
hCh33LBArC1IvkOpZE87ExdblY+IXLJDf+dFTIy69IH6PzQq2Bgyzjgh9qKvaEl/
fjgPQ7j5cPI8BGwEvRV+gqEruScZx9CKww85IOFPA7t5neqiTvY=
=8v8x
-----END PGP SIGNATURE-----
--=-=-=--
