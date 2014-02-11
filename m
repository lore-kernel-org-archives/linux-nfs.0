Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:33790 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148AbaBKCaY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Feb 2014 21:30:24 -0500
Date: Tue, 11 Feb 2014 13:30:13 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: "nosharecache" option prevent "mount" from detecting when the mount
 is a duplicate.
Message-ID: <20140211133013.1ccf8615@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Ty/.2vo_7gRtvpJgfOsDxVe"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Ty/.2vo_7gRtvpJgfOsDxVe
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


(I seem to have quite a pile of NFS issues lately.... some if it is tidying=
 up
issues from before Christmas, some of it just keeps on coming :-)

If you run "mount -a" it will attempt to mount all filesystems listed
in /etc/fstab, but filesystems that are already mounted will not be mounted
again.  So it is normally safe to run "mount -a" multiple times.

However if an NFS mount in /etc/fstab has the "nosharecache" option set,
mount doesn't notice that it is already mounted as so mounts it again.  So
repeated "mount -a" is no longer safe.

This happens because the prevention of multiple mounts happens in do_add_mo=
unt
in fs/namespace.c:

	err =3D -EBUSY;
	if (path->mnt->mnt_sb =3D=3D newmnt->mnt.mnt_sb &&
	    path->mnt->mnt_root =3D=3D path->dentry)
		goto unlock;


i.e. if the exact same superblock is being mounted in the exact same place,
return EBUSY.
With nosharecache, every mount attempt produces a new superblock so this te=
st
never fires.

One way to address this would be to have a different option, e.g.
          sharecache=3D27

where the '27' is an arbitrary number meaning that if two mount attempts ha=
ve
different sharecache numbers they will have different superblocks.  If they
have the same sharecache number they can have the same superblock.
This is not the most elegant interface ever and I would be very happy for
suggestions to improve it.  Maybe a string rather than a number ???

This probably isn't a very serious issue, but is a regression in terms of t=
he
usability of "mount -a" and I think it would be best to fix it if the cost =
is
not too high.

Below is my patch to implement the "sharecache=3D%u" syntax.

Any ideas?

Thanks,
NeilBrown

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1d09289c8f0e..7ed2f1e37a18 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -779,6 +779,7 @@ static int nfs_init_server(struct nfs_server *server,
 	server->acregmax =3D data->acregmax * HZ;
 	server->acdirmin =3D data->acdirmin * HZ;
 	server->acdirmax =3D data->acdirmax * HZ;
+	server->cache_id =3D data->cache_id;
=20
 	/* Start lockd here, before we might error out */
 	error =3D nfs_start_lockd(server);
@@ -931,6 +932,7 @@ void nfs_server_copy_userdata(struct nfs_server *target=
, struct nfs_server *sour
 	target->caps =3D source->caps;
 	target->options =3D source->options;
 	target->auth_info =3D source->auth_info;
+	target->cache_id =3D source->cache_id;
 }
 EXPORT_SYMBOL_GPL(nfs_server_copy_userdata);
=20
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8b5cc04a8611..b1c2b9164f25 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -95,6 +95,7 @@ struct nfs_parsed_mount_data {
 	unsigned int		minorversion;
 	char			*fscache_uniq;
 	bool			need_mount;
+	unsigned int		cache_id;
=20
 	struct {
 		struct sockaddr_storage	address;
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index dbb3e1f30c68..25f426db68f9 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -997,6 +997,7 @@ static int nfs4_init_server(struct nfs_server *server,
 	server->acregmax =3D data->acregmax * HZ;
 	server->acdirmin =3D data->acdirmin * HZ;
 	server->acdirmax =3D data->acdirmax * HZ;
+	server->cache_id =3D data->cache_id;
=20
 	server->port =3D data->nfs_server.port;
=20
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 910ed906eb82..27edb581affa 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -103,6 +103,7 @@ enum {
 	Opt_mountport,
 	Opt_mountvers,
 	Opt_minorversion,
+	Opt_sharecacheid,
=20
 	/* Mount options that take string arguments */
 	Opt_nfsvers,
@@ -145,6 +146,7 @@ static const match_table_t nfs_mount_option_tokens =3D {
 	{ Opt_rdirplus, "rdirplus" },
 	{ Opt_nordirplus, "nordirplus" },
 	{ Opt_sharecache, "sharecache" },
+	{ Opt_sharecacheid, "sharecache=3D%s" },
 	{ Opt_nosharecache, "nosharecache" },
 	{ Opt_resvport, "resvport" },
 	{ Opt_noresvport, "noresvport" },
@@ -665,6 +667,10 @@ static void nfs_show_mount_options(struct seq_file *m,=
 struct nfs_server *nfss,
 		else
 			seq_puts(m, nfs_infop->nostr);
 	}
+	if (!(nfss->flags & NFS_MOUNT_UNSHARED) &&
+	    nfss->cache_id)
+		seq_printf(m, ",sharecache=3D%u", nfss->cache_id);
+
 	rcu_read_lock();
 	seq_printf(m, ",proto=3D%s",
 		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_NETID));
@@ -1407,6 +1413,12 @@ static int nfs_parse_mount_options(char *raw,
 				goto out_invalid_value;
 			mnt->minorversion =3D option;
 			break;
+		case Opt_sharecacheid:
+			if (nfs_get_option_ul(args, &option) ||
+			    option <=3D 0)
+				goto out_invalid_value;
+			mnt->cache_id =3D option;
+			break;
=20
 		/*
 		 * options that take text values
@@ -2457,6 +2469,9 @@ static int nfs_compare_super(struct super_block *sb, =
void *data)
 	/* Note: NFS_MOUNT_UNSHARED =3D=3D NFS4_MOUNT_UNSHARED */
 	if (old->flags & NFS_MOUNT_UNSHARED)
 		return 0;
+	if ((old->cache_id || server->cache_id) &&
+	    old->cache_id !=3D server->cache_id)
+		return 0;
 	if (memcmp(&old->fsid, &server->fsid, sizeof(old->fsid)) !=3D 0)
 		return 0;
 	return nfs_compare_mount_options(sb, server, mntflags);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 1150ea41b626..8e66d95283e1 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -145,6 +145,7 @@ struct nfs_server {
 #define NFS_OPTION_FSCACHE	0x00000001	/* - local caching enabled */
 #define NFS_OPTION_MIGRATION	0x00000002	/* - NFSv4 migration enabled */
=20
+	unsigned int		cache_id;	/* For NFS_MOUNT_UNSHARED */
 	struct nfs_fsid		fsid;
 	__u64			maxfilesize;	/* maximum file size */
 	struct timespec		time_delta;	/* smallest time granularity */

--Sig_/Ty/.2vo_7gRtvpJgfOsDxVe
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvmLNTnsnt1WYoG5AQKvwg/+IHvV6Znq+DA/rdySBJNI6MI08hE/yCEu
yPCHbLX7BqoUrMe5vGOIuClZs+7fIgixwWyNhAxDq6PwibRMYxaIZaD27cxoyNCb
2HMvY82XgfSuG6+glI1guQ0U24QpdnZQdRWw3PaxVwKDWPwDCL7qsRXAZcd3v0aL
G6DvT3TZiQPqQJo5FnETQRsMKrMkxs38gelacYCXUHxSaV35w6/8egBIDkG0hAYu
f25i6LwAzaBoI/JBJoiYXU5oFP5uNLWcKrkSWMfG/loxjdMdSd1CoLXPxHkfZ55S
AXX6med7HpjVdyLyU9HahMcmgi8vFvygvBAxwtypIrW9mQS7adFfN4aVckbbSEHr
WSqmrFuYZocm55AmSlYQKA3Boxkgisp3oQJvVlNIN4rEb+7HXzvVXvF/lorxfIBA
f7xszx8GCeFd0CMZtleG4p3trK6S8SC/ckxYCWle2/e4IoBzu51jbWlKpdaFSlYF
94tuygjPbj9186wRH1xtqJq3Vy8RQn9SHMUTSklU0UOCUVOiKEkWCYjtKh2uBWLd
EKtdlqMY9L2DJltefhLrAoytAT96/uyHDnUJo793nzERomK4pFpqDMinMiV0okjs
/06hK0cEGTH7TA8p9OEc6GCBkPHkkKviG3c2X5ysKfBHzwFlwIA3OMXDB3O/1UCu
tqjvXXb7wt0=
=+au7
-----END PGP SIGNATURE-----

--Sig_/Ty/.2vo_7gRtvpJgfOsDxVe--
