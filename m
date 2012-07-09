Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:63702 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033Ab2GIPpb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2012 11:45:31 -0400
Received: by yenl2 with SMTP id l2so10191492yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jul 2012 08:45:31 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/14] NFS: Add nfs4_unique_id boot parameter
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 Jul 2012 11:45:29 -0400
Message-ID: <20120709154529.1604.25190.stgit@degas.1015granger.net>
In-Reply-To: <20120709153355.1604.14102.stgit@degas.1015granger.net>
References: <20120709153355.1604.14102.stgit@degas.1015granger.net>
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
 fs/nfs/nfs4proc.c                     |   12 ++++++++-
 3 files changed, 57 insertions(+), 4 deletions(-)

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
index a92c5eb..733b5ab 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1720,6 +1720,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
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
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d454e3b..586d88b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -74,6 +74,12 @@
 
 static unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;
 
+#define NFS4_CLIENT_ID_UNIQ_LEN		(64)
+static char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN] = "";
+module_param_string(nfs4_unique_id, nfs4_client_id_uniquifier,
+			NFS4_CLIENT_ID_UNIQ_LEN, 0600);
+MODULE_PARM_DESC(nfs4_unique_id, "nfs_client_id4 uniquifier string");
+
 struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
@@ -4051,9 +4057,13 @@ static unsigned int
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

