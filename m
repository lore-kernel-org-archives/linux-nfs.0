Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:33657 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363Ab1LIPYF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2011 10:24:05 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Fri, 9 Dec 2011 08:24:05 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB9FNhed146602
	for <linux-nfs@vger.kernel.org>; Fri, 9 Dec 2011 08:23:44 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB9FNgJi008828
	for <linux-nfs@vger.kernel.org>; Fri, 9 Dec 2011 08:23:43 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v2 1/7] New mount option for volatile filehandle recovery
Date: Fri,  9 Dec 2011 10:23:26 -0500
Message-Id: <1323444212-9855-2-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1323444212-9855-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1323444212-9855-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new 'vfhretry' mount option will be used to enable the volatile filehandle
recovery routines in the client. On an expired filehandle recover the client
will attempt to recover by performing a lookup on the name of the file.

This option enables volatile filehandle recovery by re-lookup on FHEXPIRED
errors. Only use this mount option if the filenames/paths on the server are not
going to change from the initial expiration until all the recovery operations
complete. Otherwise the validity of the files recovered from the server can not
be guaranteed. It can only truly be considered safe to use this recovery
mechanism on a Linux server, if the filesystem is read-only.

This mechanism of recovery isn't necessarily safe for a posix filesystem so
using the mount option will allow the user to enable this at their own risk.
If the mount option is not turned on, the FHEXPIRED error will be converted to
ESTALE.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/super.c            |    6 ++++++
 include/linux/nfs_mount.h |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1347774..f63229f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -87,6 +87,7 @@ enum {
 	Opt_sharecache, Opt_nosharecache,
 	Opt_resvport, Opt_noresvport,
 	Opt_fscache, Opt_nofscache,
+	Opt_vfhretry,
 
 	/* Mount options that take integer arguments */
 	Opt_port,
@@ -149,6 +150,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_noresvport, "noresvport" },
 	{ Opt_fscache, "fsc" },
 	{ Opt_nofscache, "nofsc" },
+	{ Opt_vfhretry, "vfhretry" },
 
 	{ Opt_port, "port=%s" },
 	{ Opt_rsize, "rsize=%s" },
@@ -650,6 +652,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
 		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
 		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
+		{ NFS_MOUNT_VFHRETRY, ",vfhretry", ""},
 		{ 0, NULL, NULL }
 	};
 	const struct proc_nfs_info *nfs_infop;
@@ -1203,6 +1206,9 @@ static int nfs_parse_mount_options(char *raw,
 			kfree(mnt->fscache_uniq);
 			mnt->fscache_uniq = NULL;
 			break;
+		case Opt_vfhretry:
+			mnt->flags |= NFS_MOUNT_VFHRETRY;
+			break;
 
 		/*
 		 * options that take numeric values
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index 576bddd..dba0e23 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -73,5 +73,6 @@ struct nfs_mount_data {
 
 #define NFS_MOUNT_LOCAL_FLOCK	0x100000
 #define NFS_MOUNT_LOCAL_FCNTL	0x200000
+#define NFS_MOUNT_VFHRETRY	0x400000
 
 #endif
-- 
1.7.4.4

