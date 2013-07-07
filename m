Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:36411 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254Ab3GGX6Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Jul 2013 19:58:24 -0400
Date: Mon, 8 Jul 2013 09:58:12 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH - RFC]  new "nosharetransport" option for NFS mounts.
Message-ID: <20130708095812.355d7cfc@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Wma47l/ZoFUNKrG8IMCGOfc"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Wma47l/ZoFUNKrG8IMCGOfc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



This patch adds a "nosharetransport" option to allow two different
mounts from the same server to use different transports.
If the mounts use NFSv4, or are of the same filesystem, then
"nosharecache" must be used as well.

There are at least two circumstances where it might be desirable
to use separate transports:

1/ If the NFS server can get into a state where it will ignore
  requests for one filesystem while servicing request for another,
  then using separate connections for the separate filesystems can
  stop problems with one affecting access to the other.

  This is particularly relevant for NetApp filers where one filesystem
  has been "suspended".  Requests to that filesystem will be dropped
  (rather than the more correct NFS3ERR_JUKEBOX).  This currently
  interferes with other filesystems.

2/ If a very fast network is used with a many-processor client, a
  single TCP connection can present a bottle neck which reduces total
  throughput.  Using multiple TCP connections (one per mount) removes
  the bottleneck.
  An alternate workaround is to configure multiple virtual IP
  addresses on the server and mount each filesystem from a different
  IP.  This is effective (throughput goes up) but an unnecessary
  administrative burden.

Signed-off-by: NeilBrown <neilb@suse.de>

---
Is this a good idea?  Bad idea?  Have I missed something important?

NeilBrown


diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c513b0c..64e3f39 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -403,8 +403,13 @@ static struct nfs_client *nfs_match_client(const struc=
t nfs_client_initdata *dat
 	const struct sockaddr *sap =3D data->addr;
 	struct nfs_net *nn =3D net_generic(data->net, nfs_net_id);
=20
+	if (test_bit(NFS_CS_NO_SHARE, &data->init_flags))
+		return NULL;
+
 	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
 	        const struct sockaddr *clap =3D (struct sockaddr *)&clp->cl_addr;
+		if (test_bit(NFS_CS_NO_SHARE,&clp->cl_flags))
+			continue;
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
@@ -753,6 +758,8 @@ static int nfs_init_server(struct nfs_server *server,
 			data->timeo, data->retrans);
 	if (data->flags & NFS_MOUNT_NORESVPORT)
 		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
+	if (data->flags & NFS_MOUNT_NOSHARE_XPRT)
+		set_bit(NFS_CS_NO_SHARE, &cl_init.init_flags);
 	if (server->options & NFS_OPTION_MIGRATION)
 		set_bit(NFS_CS_MIGRATION, &cl_init.init_flags);
=20
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2d7525f..d9141d8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -88,6 +88,7 @@ enum {
 	Opt_acl, Opt_noacl,
 	Opt_rdirplus, Opt_nordirplus,
 	Opt_sharecache, Opt_nosharecache,
+	Opt_sharetransport, Opt_nosharetransport,
 	Opt_resvport, Opt_noresvport,
 	Opt_fscache, Opt_nofscache,
 	Opt_migration, Opt_nomigration,
@@ -146,6 +147,8 @@ static const match_table_t nfs_mount_option_tokens =3D {
 	{ Opt_nordirplus, "nordirplus" },
 	{ Opt_sharecache, "sharecache" },
 	{ Opt_nosharecache, "nosharecache" },
+	{ Opt_sharetransport, "sharetransport"},
+	{ Opt_nosharetransport, "nosharetransport"},
 	{ Opt_resvport, "resvport" },
 	{ Opt_noresvport, "noresvport" },
 	{ Opt_fscache, "fsc" },
@@ -634,6 +637,7 @@ static void nfs_show_mount_options(struct seq_file *m, =
struct nfs_server *nfss,
 		{ NFS_MOUNT_NOACL, ",noacl", "" },
 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
 		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
+		{ NFS_MOUNT_NOSHARE_XPRT, ",nosharetransport", ""},
 		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
 		{ 0, NULL, NULL }
 	};
@@ -1239,6 +1243,12 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_nosharecache:
 			mnt->flags |=3D NFS_MOUNT_UNSHARED;
 			break;
+		case Opt_sharetransport:
+			mnt->flags &=3D ~NFS_MOUNT_NOSHARE_XPRT;
+			break;
+		case Opt_nosharetransport:
+			mnt->flags |=3D NFS_MOUNT_NOSHARE_XPRT;
+			break;
 		case Opt_resvport:
 			mnt->flags &=3D ~NFS_MOUNT_NORESVPORT;
 			break;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 3b7fa2a..9e9d7d3 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -41,6 +41,7 @@ struct nfs_client {
 #define NFS_CS_DISCRTRY		1		/* - disconnect on RPC retry */
 #define NFS_CS_MIGRATION	2		/* - transparent state migr */
 #define NFS_CS_INFINITE_SLOTS	3		/* - don't limit TCP slots */
+#define NFS_CS_NO_SHARE		4		/* - don't share across mounts */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
diff --git a/include/uapi/linux/nfs_mount.h b/include/uapi/linux/nfs_mount.h
index 576bddd..81c49ff 100644
--- a/include/uapi/linux/nfs_mount.h
+++ b/include/uapi/linux/nfs_mount.h
@@ -73,5 +73,6 @@ struct nfs_mount_data {
=20
 #define NFS_MOUNT_LOCAL_FLOCK	0x100000
 #define NFS_MOUNT_LOCAL_FCNTL	0x200000
+#define NFS_MOUNT_NOSHARE_XPRT	0x400000
=20
 #endif

--Sig_/Wma47l/ZoFUNKrG8IMCGOfc
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUdoAlDnsnt1WYoG5AQKMFxAAndFGzR29t7yD57l9QgmcWl3KKDmBbX4p
qe2/FBOOnw0fMVGT4lGdMSy0p/US0f3eG4LQJ29xdQ7FPlpKp72NYKzuMW/fm53T
HcWfzZ7ZYVkf14ovtJDBQonG+x+zJmZ5nLyuzoLydoV9GYqgqqdP/gFrM11k5cHj
Z0hWro8KD+Fxgq6gyA1mePrYgYmS9CXtB3N36kLezhzQkjHc4+lt8I/v3/DK+G74
APQizlM3AT8h4XfmqJFzGq/1u0dBPednQTR4/DPPa4P2eWhtvYUBetuqCCddTomc
weI4vpB6uHsc/Ezl4LDkCqfcTPgTMudu+n+8TjaFE4QkDEB/LA7YCS4f3icP6zZb
vTxfR5Mf+Wb9W/oo7BMYV0xERn25RIbnA3Kt19OV0ifI7tU2aV9OoXUwXt7MrDae
wJKFfVjNvBbgY8OqJyFUx//IVPeQ1YOEaSpvnmxzC4U6UuuI2YEBrMGHvtPxC5FS
YST3bpgiwXg7kgvSMsdg7hqSNXcw7q7nZq/xcCNO7aANRSSsZ5hLUlzqI//4DGqN
ob2u2/3d0h16gwFn07wiYC29urpd8XsM9ObWjoQxTNnsyaBnlkRAy72uEq9H9e/w
bQaILgckY0Xr+RFYoU0ITSmrTt6PCSIZxemlStOU7gZ1AQYcVrtvOfFF+g204+ge
t75oNpB68WQ=
=H63m
-----END PGP SIGNATURE-----

--Sig_/Wma47l/ZoFUNKrG8IMCGOfc--
