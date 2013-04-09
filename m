Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-vbr10.xs4all.nl ([194.109.24.30]:4792 "EHLO
	smtp-vbr10.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759513Ab3DINBf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2013 09:01:35 -0400
Date: Tue, 9 Apr 2013 14:50:11 +0200
From: Miquel van Smoorenburg <mikevs@xs4all.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] "sloppycto=N" mount option
Message-ID: <20130409125010.GB15231@xs4all.net>
References: <20130409124600.GA15201@xs4all.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130409124600.GA15201@xs4all.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2/2: "sloppycto=N" mount option

     This mount option is a bit like like "nocto" - it suppresses
     a GETATTR call when a file is opened if we still have valid
     attribute data in the cache. The difference is that 1) we
     only do this for files that are opened read-only and 2) only
     when the last attribute update was 'N' seconds or less ago.

diff -ruN linux-3.9-rc6.orig/include/linux/namei.h linux-3.9-rc6/include/linux/namei.h
--- linux-3.9-rc6.orig/include/linux/namei.h	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/include/linux/namei.h	2013-04-08 15:53:44.546470854 +0200
@@ -55,6 +55,7 @@
 #define LOOKUP_JUMPED		0x1000
 #define LOOKUP_ROOT		0x2000
 #define LOOKUP_EMPTY		0x4000
+#define LOOKUP_WRITE		0x8000
 
 extern int user_path_at(int, const char __user *, unsigned, struct path *);
 extern int user_path_at_empty(int, const char __user *, unsigned, struct path *, int *empty);
diff -ruN linux-3.9-rc6.orig/include/linux/nfs_fs_sb.h linux-3.9-rc6/include/linux/nfs_fs_sb.h
--- linux-3.9-rc6.orig/include/linux/nfs_fs_sb.h	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/include/linux/nfs_fs_sb.h	2013-04-08 15:44:15.726470599 +0200
@@ -124,6 +124,7 @@
 	unsigned int		acregmax;
 	unsigned int		acdirmin;
 	unsigned int		acdirmax;
+	unsigned int		sloppycto;
 	unsigned int		namelen;
 	unsigned int		options;	/* extra options enabled by mount */
 #define NFS_OPTION_FSCACHE	0x00000001	/* - local caching enabled */
diff -ruN linux-3.9-rc6.orig/fs/nfs/client.c linux-3.9-rc6/fs/nfs/client.c
--- linux-3.9-rc6.orig/fs/nfs/client.c	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/fs/nfs/client.c	2013-04-08 15:44:15.714470488 +0200
@@ -779,6 +779,7 @@
 	server->acregmax = data->acregmax * HZ;
 	server->acdirmin = data->acdirmin * HZ;
 	server->acdirmax = data->acdirmax * HZ;
+	server->sloppycto = data->sloppycto * HZ;
 
 	/* Start lockd here, before we might error out */
 	error = nfs_start_lockd(server);
@@ -859,6 +860,7 @@
 	if (server->flags & NFS_MOUNT_NOAC) {
 		server->acregmin = server->acregmax = 0;
 		server->acdirmin = server->acdirmax = 0;
+		server->sloppycto = 0;
 	}
 
 	server->maxfilesize = fsinfo->maxfilesize;
@@ -926,6 +928,7 @@
 	target->acregmax = source->acregmax;
 	target->acdirmin = source->acdirmin;
 	target->acdirmax = source->acdirmax;
+	target->sloppycto = source->sloppycto;
 	target->caps = source->caps;
 	target->options = source->options;
 }
diff -ruN linux-3.9-rc6.orig/fs/nfs/dir.c linux-3.9-rc6/fs/nfs/dir.c
--- linux-3.9-rc6.orig/fs/nfs/dir.c	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/fs/nfs/dir.c	2013-04-08 15:52:33.602470466 +0200
@@ -972,6 +972,22 @@
 }
 
 /*
+ * See if we allow sloppy close-to-open consistency.
+ */
+static inline
+int sloppycto(struct inode *inode, int flags)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	return	S_ISREG(inode->i_mode) &&
+		!(flags & LOOKUP_WRITE) &&
+		server->sloppycto &&
+		time_in_range_open(jiffies, nfsi->attrtimeo_timestamp,
+			nfsi->attrtimeo_timestamp + server->sloppycto);
+}
+
+/*
  * Inode and filehandle revalidation for lookups.
  *
  * We force revalidation in the cases where the VFS sets LOOKUP_REVAL,
@@ -991,7 +1007,8 @@
 	if (flags & LOOKUP_REVAL)
 		goto out_force;
 	/* This is an open(2) */
-	if ((flags & LOOKUP_OPEN) && !(server->flags & NFS_MOUNT_NOCTO) &&
+	if ((flags & LOOKUP_OPEN) &&
+	    !(server->flags & NFS_MOUNT_NOCTO) && !sloppycto(inode, flags) &&
 	    (S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)))
 		goto out_force;
 out:
diff -ruN linux-3.9-rc6.orig/fs/nfs/fscache.c linux-3.9-rc6/fs/nfs/fscache.c
--- linux-3.9-rc6.orig/fs/nfs/fscache.c	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/fs/nfs/fscache.c	2013-04-08 15:44:15.722470552 +0200
@@ -89,6 +89,7 @@
 	key->key.nfs_server.acregmax = nfss->acregmax;
 	key->key.nfs_server.acdirmin = nfss->acdirmin;
 	key->key.nfs_server.acdirmax = nfss->acdirmax;
+	key->key.nfs_server.sloppycto = nfss->sloppycto;
 	key->key.nfs_server.fsid = nfss->fsid;
 	key->key.rpc_auth.au_flavor = nfss->client->cl_auth->au_flavor;
 
diff -ruN linux-3.9-rc6.orig/fs/nfs/fscache.h linux-3.9-rc6/fs/nfs/fscache.h
--- linux-3.9-rc6.orig/fs/nfs/fscache.h	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/fs/nfs/fscache.h	2013-04-08 15:44:15.722470552 +0200
@@ -43,6 +43,7 @@
 			unsigned int	acregmax;
 			unsigned int	acdirmin;
 			unsigned int	acdirmax;
+			unsigned int	sloppycto;
 		} nfs_server;
 
 		struct {
diff -ruN linux-3.9-rc6.orig/fs/nfs/internal.h linux-3.9-rc6/fs/nfs/internal.h
--- linux-3.9-rc6.orig/fs/nfs/internal.h	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/fs/nfs/internal.h	2013-04-08 15:44:15.726470599 +0200
@@ -82,6 +82,7 @@
 	int			flags;
 	unsigned int		rsize, wsize;
 	unsigned int		timeo, retrans;
+	unsigned int		sloppycto;
 	unsigned int		acregmin, acregmax,
 				acdirmin, acdirmax;
 	unsigned int		namlen;
diff -ruN linux-3.9-rc6.orig/fs/nfs/nfs4client.c linux-3.9-rc6/fs/nfs/nfs4client.c
--- linux-3.9-rc6.orig/fs/nfs/nfs4client.c	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/fs/nfs/nfs4client.c	2013-04-08 15:44:15.726470599 +0200
@@ -795,6 +795,7 @@
 	server->acregmax = data->acregmax * HZ;
 	server->acdirmin = data->acdirmin * HZ;
 	server->acdirmax = data->acdirmax * HZ;
+	server->sloppycto = data->sloppycto * HZ;
 
 	server->port = data->nfs_server.port;
 
diff -ruN linux-3.9-rc6.orig/fs/nfs/super.c linux-3.9-rc6/fs/nfs/super.c
--- linux-3.9-rc6.orig/fs/nfs/super.c	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/fs/nfs/super.c	2013-04-08 15:44:15.726470599 +0200
@@ -98,6 +98,7 @@
 	Opt_timeo, Opt_retrans,
 	Opt_acregmin, Opt_acregmax,
 	Opt_acdirmin, Opt_acdirmax,
+	Opt_sloppycto,
 	Opt_actimeo,
 	Opt_namelen,
 	Opt_mountport,
@@ -163,6 +164,7 @@
 	{ Opt_acregmax, "acregmax=%s" },
 	{ Opt_acdirmin, "acdirmin=%s" },
 	{ Opt_acdirmax, "acdirmax=%s" },
+	{ Opt_sloppycto, "sloppycto=%s" },
 	{ Opt_actimeo, "actimeo=%s" },
 	{ Opt_namelen, "namlen=%s" },
 	{ Opt_mountport, "mountport=%s" },
@@ -656,6 +658,8 @@
 		seq_printf(m, ",acdirmin=%u", nfss->acdirmin/HZ);
 	if (nfss->acdirmax != NFS_DEF_ACDIRMAX*HZ || showdefaults)
 		seq_printf(m, ",acdirmax=%u", nfss->acdirmax/HZ);
+	if (nfss->sloppycto != 0)
+		seq_printf(m, ",sloppycto=%u", nfss->sloppycto/HZ);
 	for (nfs_infop = nfs_info; nfs_infop->flag; nfs_infop++) {
 		if (nfss->flags & nfs_infop->flag)
 			seq_puts(m, nfs_infop->str);
@@ -1316,6 +1320,11 @@
 				goto out_invalid_value;
 			mnt->acdirmax = option;
 			break;
+		case Opt_sloppycto:
+			if (nfs_get_option_ul(args, &option))
+				goto out_invalid_value;
+			mnt->sloppycto = option;
+			break;
 		case Opt_actimeo:
 			if (nfs_get_option_ul(args, &option))
 				goto out_invalid_value;
@@ -2074,6 +2083,7 @@
 	    data->acregmax != nfss->acregmax / HZ ||
 	    data->acdirmin != nfss->acdirmin / HZ ||
 	    data->acdirmax != nfss->acdirmax / HZ ||
+	    data->sloppycto != nfss->sloppycto / HZ ||
 	    data->timeo != (10U * nfss->client->cl_timeout->to_initval / HZ) ||
 	    data->nfs_server.port != nfss->port ||
 	    data->nfs_server.addrlen != nfss->nfs_client->cl_addrlen ||
@@ -2245,6 +2255,8 @@
 		goto Ebusy;
 	if (a->acdirmax != b->acdirmax)
 		goto Ebusy;
+	if (a->sloppycto != b->sloppycto)
+		goto Ebusy;
 	if (clnt_a->cl_auth->au_flavor != clnt_b->cl_auth->au_flavor)
 		goto Ebusy;
 	return 1;
diff -ruN linux-3.9-rc6.orig/fs/open.c linux-3.9-rc6/fs/open.c
--- linux-3.9-rc6.orig/fs/open.c	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/fs/open.c	2013-04-08 15:57:34.818470456 +0200
@@ -899,6 +899,8 @@
 		if (flags & O_EXCL)
 			op->intent |= LOOKUP_EXCL;
 	}
+	if (flags & (O_RDWR|O_WRONLY|O_CREAT))
+		op->intent |= LOOKUP_WRITE;
 
 	if (flags & O_DIRECTORY)
 		lookup_flags |= LOOKUP_DIRECTORY;
