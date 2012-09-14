Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:64423 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409Ab2INVYo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Sep 2012 17:24:44 -0400
Received: by yenm15 with SMTP id m15so315684yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 14 Sep 2012 14:24:44 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/10] NFS: Add nfs4_unique_id boot parameter
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 14 Sep 2012 17:24:41 -0400
Message-ID: <20120914212441.1635.55575.stgit@degas.1015granger.net>
In-Reply-To: <20120914211053.1635.74063.stgit@degas.1015granger.net>
References: <20120914211053.1635.74063.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An optional boot parameter is introduced to allow client
administrators to specify a string that the Linux NFS client can
insert into its nfs_client_id4 id string, to make it both more
globally unique, and to ensure that it doesn't change even if the
client's nodename changes.

If this boot parameter is not specified, the client's nodename is
used, as before.

Client installation procedures can create a unique string (typically,
a UUID) which remains unchanged during the lifetime of that client
instance.  This works just like creating a UUID for the label of the
system's root and boot volumes.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 Documentation/filesystems/nfs/nfs.txt |   44 +++++++++++++++++++++++++++++++--
 Documentation/kernel-parameters.txt   |    5 ++++
 fs/nfs/nfs4_fs.h                      |    3 ++
 fs/nfs/nfs4proc.c                     |    6 ++++-
 fs/nfs/super.c                        |    5 ++++
 5 files changed, 59 insertions(+), 4 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfs.txt b/Documentation/filesystems/nfs/nfs.txt
index f50f26c..f2571c8 100644
--- a/Documentation/filesystems/nfs/nfs.txt
+++ b/Documentation/filesystems/nfs/nfs.txt
@@ -12,9 +12,47 @@ and work is in progress on adding support for minor version 1 of the NFSv4
 protocol.
 
 The purpose of this document is to provide information on some of the
-upcall interfaces that are used in order to provide the NFS client with
-some of the information that it requires in order to fully comply with
-the NFS spec.
+special features of the NFS client that can be configured by system
+administrators.
+
+
+The nfs4_unique_id parameter
+============================
+
+NFSv4 requires clients to identify themselves to servers with a unique
+string.  File open and lock state shared between one client and one server
+is associated with this identity.  To support robust NFSv4 state recovery
+and transparent state migration, this identity string must not change
+across client reboots.
+
+Without any other intervention, the Linux client uses a string that contains
+the local system's node name.  System administrators, however, often do not
+take care to ensure that node names are fully qualified and do not change
+over the lifetime of a client system.  Node names can have other
+administrative requirements that require particular behavior that does not
+work well as part of an nfs_client_id4 string.
+
+The nfs.nfs4_unique_id boot parameter specifies a unique string that can be
+used instead of a system's node name when an NFS client identifies itself to
+a server.  Thus, if the system's node name is not unique, or it changes, its
+nfs.nfs4_unique_id stays the same, preventing collision with other clients
+or loss of state during NFS reboot recovery or transparent state migration.
+
+The nfs.nfs4_unique_id string is typically a UUID, though it can contain
+anything that is believed to be unique across all NFS clients.  An
+nfs4_unique_id string should be chosen when a client system is installed,
+just as a system's root file system gets a fresh UUID in its label at
+install time.
+
+The string should remain fixed for the lifetime of the client.  It can be
+changed safely if care is taken that the client shuts down cleanly and all
+outstanding NFSv4 state has expired, to prevent loss of NFSv4 state.
+
+This string can be stored in an NFS client's grub.conf, or it can be provided
+via a net boot facility such as PXE.  It may also be specified as an nfs.ko
+module parameter.  Specifying a uniquifier string is not support for NFS
+clients running in containers.
+
 
 The DNS resolver
 ================
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index ad7e2e5..396a1e6 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1719,6 +1719,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			will be autodetected by the client, and it will fall
 			back to using the idmapper.
 			To turn off this behaviour, set the value to '0'.
+	nfs.nfs4_unique_id=
+			[NFS4] Specify an additional fixed unique ident-
+			ification string that NFSv4 clients can insert into
+			their nfs_client_id4 string.  This is typically a
+			UUID that is generated at system install time.
 
 	nfs.send_implementation_id =
 			[NFSv4.1] Send client implementation identification
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c8e0998..bf54671 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -380,6 +380,9 @@ extern bool nfs4_disable_idmapping;
 extern unsigned short max_session_slots;
 extern unsigned short send_implementation_id;
 
+#define NFS4_CLIENT_ID_UNIQ_LEN		(64)
+extern char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN];
+
 /* nfs4sysctl.c */
 #ifdef CONFIG_SYSCTL
 int nfs4_register_sysctl(void);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e344f13..f456f5f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4033,9 +4033,13 @@ static unsigned int
 nfs4_init_uniform_client_string(const struct nfs_client *clp,
 				char *buf, size_t len)
 {
+	char *nodename = clp->cl_rpcclient->cl_nodename;
+
+	if (nfs4_client_id_uniquifier[0] != '\0')
+		nodename = nfs4_client_id_uniquifier;
 	return scnprintf(buf, len, "Linux NFSv%u.%u %s",
 				clp->rpc_ops->version, clp->cl_minorversion,
-				clp->cl_rpcclient->cl_nodename);
+				nodename);
 }
 
 /**
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4aabf19..77d95d0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2660,6 +2660,7 @@ unsigned int nfs_idmap_cache_timeout = 600;
 bool nfs4_disable_idmapping = true;
 unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;
 unsigned short send_implementation_id = 1;
+char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN] = "";
 
 EXPORT_SYMBOL_GPL(nfs_callback_set_tcpport);
 EXPORT_SYMBOL_GPL(nfs_callback_tcpport);
@@ -2667,6 +2668,7 @@ EXPORT_SYMBOL_GPL(nfs_idmap_cache_timeout);
 EXPORT_SYMBOL_GPL(nfs4_disable_idmapping);
 EXPORT_SYMBOL_GPL(max_session_slots);
 EXPORT_SYMBOL_GPL(send_implementation_id);
+EXPORT_SYMBOL_GPL(nfs4_client_id_uniquifier);
 
 #define NFS_CALLBACK_MAXPORTNR (65535U)
 
@@ -2692,6 +2694,8 @@ static struct kernel_param_ops param_ops_portnr = {
 module_param_named(callback_tcpport, nfs_callback_set_tcpport, portnr, 0644);
 module_param(nfs_idmap_cache_timeout, int, 0644);
 module_param(nfs4_disable_idmapping, bool, 0644);
+module_param_string(nfs4_unique_id, nfs4_client_id_uniquifier,
+			NFS4_CLIENT_ID_UNIQ_LEN, 0600);
 MODULE_PARM_DESC(nfs4_disable_idmapping,
 		"Turn off NFSv4 idmapping when using 'sec=sys'");
 module_param(max_session_slots, ushort, 0644);
@@ -2700,6 +2704,7 @@ MODULE_PARM_DESC(max_session_slots, "Maximum number of outstanding NFSv4.1 "
 module_param(send_implementation_id, ushort, 0644);
 MODULE_PARM_DESC(send_implementation_id,
 		"Send implementation ID with NFSv4.1 exchange_id");
+MODULE_PARM_DESC(nfs4_unique_id, "nfs_client_id4 uniquifier string");
 MODULE_ALIAS("nfs4");
 
 #endif /* CONFIG_NFS_V4 */

