Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0422DC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:59:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A5E8C2146E
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:59:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eUSgZVEI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725805AbfBSN73 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 08:59:29 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:52496 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725803AbfBSN72 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 08:59:28 -0500
Received: by mail-it1-f196.google.com with SMTP id r11so6175720itc.2
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 05:59:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=kGAmU1kz/PG3RSH0/2JNMO0HezwCInB0hpiepxVLfHA=;
        b=eUSgZVEIcTCIRugpq/FA/351f4PJtvJe6oe8hpawbMvFBA8a+g20wIMbl7/iCK/AP9
         0ZGTNeisDFZGm495d9nC5PTK00t2hbl2LEtXvxLfohGCmnkOv1I0cYzQyuzNILs2oHJ+
         h5sH0L31k8bygs9bw2un7jEoxVJpZz8IULQFJYleNDkD2SQVToEVOcRwgHhvi6K5S/pr
         0eCeFN9CNBGDVeLuZ3OhLvEtv1R6w5vPSK3MP2KxbaR0BSRXh3jhBzvNK4owf3OCh/1f
         aytS6Se3rikxgWY1WJLX1dtDQqaUA02SyNj4OaikwsWlUTTH0ZUtpOQLIKWChZXyV15s
         2LxQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=kGAmU1kz/PG3RSH0/2JNMO0HezwCInB0hpiepxVLfHA=;
        b=M6SQ8AexrT0KKBuDpwfoHdjS2YPSexOggh3P7TnOR3729nGolberOF3MKTKQtzR2LB
         Y3b87IuXLAHeiIn6AJdQJuZKOwtg+FLsXpe0oajYQOLA7hrac2bq1uvhHF/g6msXyR2j
         Tm9kic14g3OmjNuRQFiFzaoN4gcqR4BxPj/b/LYDzNWY52tixCJHdgAm6BCRPLtALD+H
         YTTrSjd3GMQUJZj7i434PEA0fMAsIbap1wTGunqb6IX5B91gqHVoBguDmmem2blGO2K5
         +G2ZwPfPqw3gCwB1vU8YA4MZa2K3s4xFiugGsOKmel7Yn9LesJWl8LmcJ67xObIs/omt
         ywbw==
X-Gm-Message-State: AHQUAuZeeb5R02ZbdqRyI7FYecFEugPJDvHfBIudp7S8TuAzAl+vkBYq
        R0BaAEYv+Vexl4Kt9Y4YVXObbpg=
X-Google-Smtp-Source: AHgI3IbH/6nw8imWLRMK/z6W+G68RDXDzJDAGQAKNL+woqqXStoSKNG34HC4MTmvspY70hbVYZtI8Q==
X-Received: by 2002:a6b:6007:: with SMTP id r7mr3743356iog.124.1550584766680;
        Tue, 19 Feb 2019 05:59:26 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id d184sm241687itc.17.2019.02.19.05.59.25
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 05:59:26 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix up documentation warnings
Date:   Tue, 19 Feb 2019 08:57:39 -0500
Message-Id: <20190219135739.119615-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix up some compiler warnings about function parameters, etc not being
correctly described or formatted.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/delegation.c                       |  2 +-
 fs/nfs/dir.c                              |  2 +-
 fs/nfs/file.c                             |  4 +--
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 12 ++++++---
 fs/nfs/inode.c                            | 33 ++++++++++++-----------
 fs/nfs/io.c                               | 12 ++++-----
 fs/nfs/namespace.c                        |  8 +++---
 fs/nfs/nfs4client.c                       | 32 ++++++++++++----------
 fs/nfs/nfs4namespace.c                    |  5 ++--
 fs/nfs/nfs4proc.c                         |  8 +++---
 fs/nfs/nfs4session.c                      |  2 +-
 fs/nfs/nfs4state.c                        |  1 +
 fs/nfs/pagelist.c                         |  7 +++--
 fs/nfs/unlink.c                           |  8 +++---
 fs/nfs/write.c                            |  1 -
 15 files changed, 75 insertions(+), 62 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 885363ca8569..70e5931f3c60 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -681,7 +681,7 @@ void nfs_expire_all_delegations(struct nfs_client *clp)
 
 /**
  * nfs_super_return_all_delegations - return delegations for one superblock
- * @sb: sb to process
+ * @server: pointer to nfs_server to process
  *
  */
 void nfs_server_return_all_delegations(struct nfs_server *server)
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 6bf4471850c8..0fb37fac88c9 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -945,7 +945,7 @@ static int nfs_fsync_dir(struct file *filp, loff_t start, loff_t end,
 
 /**
  * nfs_force_lookup_revalidate - Mark the directory as having changed
- * @dir - pointer to directory inode
+ * @dir: pointer to directory inode
  *
  * This forces the revalidation code in nfs_lookup_revalidate() to do a
  * full lookup on all child dentries of 'dir' whenever a change occurs
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 29553fdba8af..e4a33e66f417 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -89,8 +89,8 @@ EXPORT_SYMBOL_GPL(nfs_file_release);
 
 /**
  * nfs_revalidate_size - Revalidate the file size
- * @inode - pointer to inode struct
- * @file - pointer to struct file
+ * @inode: pointer to inode struct
+ * @filp: pointer to struct file
  *
  * Revalidates the file length. This is basically a wrapper around
  * nfs_revalidate_inode() that takes into account the fact that we may
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 11766a74216d..ca7a6203b3cb 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -483,9 +483,15 @@ ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32 ds_idx,
 }
 
 /**
-* Find or create a DS rpc client with th MDS server rpc client auth flavor
-* in the nfs_client cl_ds_clients list.
-*/
+ * nfs4_ff_find_or_create_ds_client - Find or create a DS rpc client
+ * @lseg: pointer to layout segment
+ * @ds_idx: mirror index
+ * @ds_clp: nfs_client for the DS
+ * @inode: pointer to inode
+ *
+ * Find or create a DS rpc client with th MDS server rpc client auth flavor
+ * in the nfs_client cl_ds_clients list.
+ */
 struct rpc_clnt *
 nfs4_ff_find_or_create_ds_client(struct pnfs_layout_segment *lseg, u32 ds_idx,
 				 struct nfs_client *ds_clp, struct inode *inode)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 094775ea0781..414a90d48493 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -143,6 +143,7 @@ EXPORT_SYMBOL_GPL(nfs_sync_inode);
 
 /**
  * nfs_sync_mapping - helper to flush all mmapped dirty data to disk
+ * @mapping: pointer to struct address_space
  */
 int nfs_sync_mapping(struct address_space *mapping)
 {
@@ -1184,8 +1185,8 @@ int nfs_attribute_cache_expired(struct inode *inode)
 
 /**
  * nfs_revalidate_inode - Revalidate the inode attributes
- * @server - pointer to nfs_server struct
- * @inode - pointer to inode struct
+ * @server: pointer to nfs_server struct
+ * @inode: pointer to inode struct
  *
  * Updates inode attribute information by retrieving the data from the server.
  */
@@ -1255,8 +1256,8 @@ int nfs_revalidate_mapping_rcu(struct inode *inode)
 
 /**
  * nfs_revalidate_mapping - Revalidate the pagecache
- * @inode - pointer to host inode
- * @mapping - pointer to mapping
+ * @inode: pointer to host inode
+ * @mapping: pointer to mapping
  */
 int nfs_revalidate_mapping(struct inode *inode,
 		struct address_space *mapping)
@@ -1371,8 +1372,8 @@ static void nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 
 /**
  * nfs_check_inode_attributes - verify consistency of the inode attribute cache
- * @inode - pointer to inode
- * @fattr - updated attributes
+ * @inode: pointer to inode
+ * @fattr: updated attributes
  *
  * Verifies the attribute cache. If we have just changed the attributes,
  * so that fattr carries weak cache consistency data, then it may
@@ -1572,8 +1573,8 @@ EXPORT_SYMBOL_GPL(_nfs_display_fhandle);
 
 /**
  * nfs_inode_attrs_need_update - check if the inode attributes need updating
- * @inode - pointer to inode
- * @fattr - attributes
+ * @inode: pointer to inode
+ * @fattr: attributes
  *
  * Attempt to divine whether or not an RPC call reply carrying stale
  * attributes got scheduled after another call carrying updated ones.
@@ -1614,8 +1615,8 @@ static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr
 
 /**
  * nfs_refresh_inode - try to update the inode attribute cache
- * @inode - pointer to inode
- * @fattr - updated attributes
+ * @inode: pointer to inode
+ * @fattr: updated attributes
  *
  * Check that an RPC call that returned attributes has not overlapped with
  * other recent updates of the inode metadata, then decide whether it is
@@ -1649,8 +1650,8 @@ static int nfs_post_op_update_inode_locked(struct inode *inode,
 
 /**
  * nfs_post_op_update_inode - try to update the inode attribute cache
- * @inode - pointer to inode
- * @fattr - updated attributes
+ * @inode: pointer to inode
+ * @fattr: updated attributes
  *
  * After an operation that has changed the inode metadata, mark the
  * attribute cache as being invalid, then try to update it.
@@ -1679,8 +1680,8 @@ EXPORT_SYMBOL_GPL(nfs_post_op_update_inode);
 
 /**
  * nfs_post_op_update_inode_force_wcc_locked - update the inode attribute cache
- * @inode - pointer to inode
- * @fattr - updated attributes
+ * @inode: pointer to inode
+ * @fattr: updated attributes
  *
  * After an operation that has changed the inode metadata, mark the
  * attribute cache as being invalid, then try to update it. Fake up
@@ -1731,8 +1732,8 @@ int nfs_post_op_update_inode_force_wcc_locked(struct inode *inode, struct nfs_fa
 
 /**
  * nfs_post_op_update_inode_force_wcc - try to update the inode attribute cache
- * @inode - pointer to inode
- * @fattr - updated attributes
+ * @inode: pointer to inode
+ * @fattr: updated attributes
  *
  * After an operation that has changed the inode metadata, mark the
  * attribute cache as being invalid, then try to update it. Fake up
diff --git a/fs/nfs/io.c b/fs/nfs/io.c
index 9034b4926909..5088fda9b453 100644
--- a/fs/nfs/io.c
+++ b/fs/nfs/io.c
@@ -25,7 +25,7 @@ static void nfs_block_o_direct(struct nfs_inode *nfsi, struct inode *inode)
 
 /**
  * nfs_start_io_read - declare the file is being used for buffered reads
- * @inode - file inode
+ * @inode: file inode
  *
  * Declare that a buffered read operation is about to start, and ensure
  * that we block all direct I/O.
@@ -56,7 +56,7 @@ nfs_start_io_read(struct inode *inode)
 
 /**
  * nfs_end_io_read - declare that the buffered read operation is done
- * @inode - file inode
+ * @inode: file inode
  *
  * Declare that a buffered read operation is done, and release the shared
  * lock on inode->i_rwsem.
@@ -69,7 +69,7 @@ nfs_end_io_read(struct inode *inode)
 
 /**
  * nfs_start_io_write - declare the file is being used for buffered writes
- * @inode - file inode
+ * @inode: file inode
  *
  * Declare that a buffered read operation is about to start, and ensure
  * that we block all direct I/O.
@@ -83,7 +83,7 @@ nfs_start_io_write(struct inode *inode)
 
 /**
  * nfs_end_io_write - declare that the buffered write operation is done
- * @inode - file inode
+ * @inode: file inode
  *
  * Declare that a buffered write operation is done, and release the
  * lock on inode->i_rwsem.
@@ -105,7 +105,7 @@ static void nfs_block_buffered(struct nfs_inode *nfsi, struct inode *inode)
 
 /**
  * nfs_end_io_direct - declare the file is being used for direct i/o
- * @inode - file inode
+ * @inode: file inode
  *
  * Declare that a direct I/O operation is about to start, and ensure
  * that we block all buffered I/O.
@@ -136,7 +136,7 @@ nfs_start_io_direct(struct inode *inode)
 
 /**
  * nfs_end_io_direct - declare that the direct i/o operation is done
- * @inode - file inode
+ * @inode: file inode
  *
  * Declare that a direct I/O operation is done, and release the shared
  * lock on inode->i_rwsem.
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index e5686be67be8..15f099a24c29 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -221,10 +221,10 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
 
 /**
  * nfs_do_submount - set up mountpoint when crossing a filesystem boundary
- * @dentry - parent directory
- * @fh - filehandle for new root dentry
- * @fattr - attributes for new root inode
- * @authflavor - security flavor to use when performing the mount
+ * @dentry: parent directory
+ * @fh: filehandle for new root dentry
+ * @fattr: attributes for new root inode
+ * @authflavor: security flavor to use when performing the mount
  *
  */
 struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 2548405da1f7..170115fc43c5 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -42,7 +42,7 @@ static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
 }
 
 #ifdef CONFIG_NFS_V4_1
-/**
+/*
  * Per auth flavor data server rpc clients
  */
 struct nfs4_ds_server {
@@ -51,7 +51,9 @@ struct nfs4_ds_server {
 };
 
 /**
- * Common lookup case for DS I/O
+ * nfs4_find_ds_client - Common lookup case for DS I/O
+ * @ds_clp: pointer to the DS's nfs_client
+ * @flavor: rpc auth flavour to match
  */
 static struct nfs4_ds_server *
 nfs4_find_ds_client(struct nfs_client *ds_clp, rpc_authflavor_t flavor)
@@ -118,9 +120,13 @@ nfs4_free_ds_server(struct nfs4_ds_server *dss)
 }
 
 /**
-* Find or create a DS rpc client with th MDS server rpc client auth flavor
-* in the nfs_client cl_ds_clients list.
-*/
+ * nfs4_find_or_create_ds_client - Find or create a DS rpc client
+ * @ds_clp: pointer to the DS's nfs_client
+ * @inode: pointer to the inode
+ *
+ * Find or create a DS rpc client with th MDS server rpc client auth flavor
+ * in the nfs_client cl_ds_clients list.
+ */
 struct rpc_clnt *
 nfs4_find_or_create_ds_client(struct nfs_client *ds_clp, struct inode *inode)
 {
@@ -284,7 +290,7 @@ static int nfs4_init_callback(struct nfs_client *clp)
 
 /**
  * nfs40_init_client - nfs_client initialization tasks for NFSv4.0
- * @clp - nfs_client to initialize
+ * @clp: nfs_client to initialize
  *
  * Returns zero on success, or a negative errno if some error occurred.
  */
@@ -312,7 +318,7 @@ int nfs40_init_client(struct nfs_client *clp)
 
 /**
  * nfs41_init_client - nfs_client initialization tasks for NFSv4.1+
- * @clp - nfs_client to initialize
+ * @clp: nfs_client to initialize
  *
  * Returns zero on success, or a negative errno if some error occurred.
  */
@@ -360,9 +366,7 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
  * nfs4_init_client - Initialise an NFS4 client record
  *
  * @clp: nfs_client to initialise
- * @timeparms: timeout parameters for underlying RPC transport
- * @ip_addr: callback IP address in presentation format
- * @authflavor: authentication flavor for underlying RPC transport
+ * @cl_init: pointer to nfs_client_initdata
  *
  * Returns pointer to an NFS client, or an ERR_PTR value.
  */
@@ -649,13 +653,13 @@ nfs4_check_server_scope(struct nfs41_server_scope *s1,
 
 /**
  * nfs4_detect_session_trunking - Checks for session trunking.
- *
- * Called after a successful EXCHANGE_ID on a multi-addr connection.
- * Upon success, add the transport.
- *
  * @clp:    original mount nfs_client
  * @res:    result structure from an exchange_id using the original mount
  *          nfs_client with a new multi_addr transport
+ * @xprt:   pointer to the transport to add.
+ *
+ * Called after a successful EXCHANGE_ID on a multi-addr connection.
+ * Upon success, add the transport.
  *
  * Returns zero on success, otherwise -EINVAL
  *
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 24f06dcc2b08..2e460c33ae48 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -137,6 +137,7 @@ static size_t nfs_parse_server_name(char *string, size_t len,
 
 /**
  * nfs_find_best_sec - Find a security mechanism supported locally
+ * @clnt: pointer to rpc_clnt
  * @server: NFS server struct
  * @flavors: List of security tuples returned by SECINFO procedure
  *
@@ -288,8 +289,8 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 
 /**
  * nfs_follow_referral - set up mountpoint when hitting a referral on moved error
- * @dentry - parent directory
- * @locations - array of NFSv4 server location information
+ * @dentry: parent directory
+ * @locations: array of NFSv4 server location information
  *
  */
 static struct vfsmount *nfs_follow_referral(struct dentry *dentry,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 557a5d636183..e8e12faa8604 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5963,7 +5963,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 /**
  * nfs4_proc_setclientid_confirm - Confirm client ID
  * @clp: state data structure
- * @res: result of a previous SETCLIENTID
+ * @arg: result of a previous SETCLIENTID
  * @cred: credential to use for this call
  *
  * Returns zero, a negative errno, or a negative NFS4ERR status code.
@@ -7527,7 +7527,7 @@ int nfs4_proc_fsid_present(struct inode *inode, const struct cred *cred)
 	return status;
 }
 
-/**
+/*
  * If 'use_integrity' is true and the state managment nfs_client
  * cl_rpcclient is using krb5i/p, use the integrity protected cl_rpcclient
  * and the machine credential as per RFC3530bis and RFC5661 Security
@@ -9219,7 +9219,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 	return status;
 }
 
-/**
+/*
  * Use the state managment nfs_client cl_rpcclient, which uses krb5i (if
  * possible) as per RFC3530bis and RFC5661 Security Considerations sections
  */
@@ -9484,7 +9484,7 @@ static const struct rpc_call_ops nfs41_free_stateid_ops = {
  * @server: server / transport on which to perform the operation
  * @stateid: state ID to release
  * @cred: credential
- * @is_recovery: set to true if this call needs to be privileged
+ * @privileged: set to true if this call needs to be privileged
  *
  * Note: this function is always asynchronous.
  */
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index a5489d70a724..25c5255a395c 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -55,7 +55,7 @@ static void nfs4_shrink_slot_table(struct nfs4_slot_table  *tbl, u32 newsize)
 
 /**
  * nfs4_slot_tbl_drain_complete - wake waiters when drain is complete
- * @tbl - controlling slot table
+ * @tbl: controlling slot table
  *
  */
 void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 02488b50534a..3de36479ed7a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -563,6 +563,7 @@ static void nfs4_gc_state_owners(struct nfs_server *server)
  * nfs4_get_state_owner - Look up a state owner given a credential
  * @server: nfs_server to search
  * @cred: RPC credential to match
+ * @gfp_flags: allocation mode
  *
  * Returns a pointer to an instantiated nfs4_state_owner struct, or NULL.
  */
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 695afb7de3a7..e9f39fa5964b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -350,7 +350,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 
 /**
  * nfs_unlock_request - Unlock request and wake up sleepers.
- * @req:
+ * @req: pointer to request
  */
 void nfs_unlock_request(struct nfs_page *req)
 {
@@ -368,7 +368,7 @@ void nfs_unlock_request(struct nfs_page *req)
 
 /**
  * nfs_unlock_and_release_request - Unlock request and release the nfs_page
- * @req:
+ * @req: pointer to request
  */
 void nfs_unlock_and_release_request(struct nfs_page *req)
 {
@@ -531,7 +531,6 @@ EXPORT_SYMBOL_GPL(nfs_pgio_header_free);
  * nfs_pgio_rpcsetup - Set up arguments for a pageio call
  * @hdr: The pageio hdr
  * @count: Number of bytes to read
- * @offset: Initial offset
  * @how: How to commit data (writes only)
  * @cinfo: Commit information for the call (writes only)
  */
@@ -634,7 +633,6 @@ EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
 
 /**
  * nfs_pgio_error - Clean up from a pageio error
- * @desc: IO descriptor
  * @hdr: pageio header
  */
 static void nfs_pgio_error(struct nfs_pgio_header *hdr)
@@ -892,6 +890,7 @@ static bool nfs_match_lock_context(const struct nfs_lock_context *l1,
  * nfs_can_coalesce_requests - test two requests for compatibility
  * @prev: pointer to nfs_page
  * @req: pointer to nfs_page
+ * @pgio: pointer to nfs_pagio_descriptor
  *
  * The nfs_page structures 'prev' and 'req' are compared to ensure that the
  * page data area they describe is contiguous, and that their RPC
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 79b97b3c4427..52d533967485 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -39,6 +39,7 @@ nfs_free_unlinkdata(struct nfs_unlinkdata *data)
 /**
  * nfs_async_unlink_done - Sillydelete post-processing
  * @task: rpc_task of the sillydelete
+ * @calldata: pointer to nfs_unlinkdata
  *
  * Do the directory attribute update.
  */
@@ -54,7 +55,7 @@ static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 
 /**
  * nfs_async_unlink_release - Release the sillydelete data.
- * @task: rpc_task of the sillydelete
+ * @calldata: struct nfs_unlinkdata to release
  *
  * We need to call nfs_put_unlinkdata as a 'tk_release' task since the
  * rpc_task would be freed too.
@@ -159,8 +160,8 @@ static int nfs_call_unlink(struct dentry *dentry, struct inode *inode, struct nf
 
 /**
  * nfs_async_unlink - asynchronous unlinking of a file
- * @dir: parent directory of dentry
- * @dentry: dentry to unlink
+ * @dentry: parent directory of dentry
+ * @name: name of dentry to unlink
  */
 static int
 nfs_async_unlink(struct dentry *dentry, const struct qstr *name)
@@ -324,6 +325,7 @@ static const struct rpc_call_ops nfs_rename_ops = {
  * @new_dir: target directory for the rename
  * @old_dentry: original dentry to be renamed
  * @new_dentry: dentry to which the old_dentry should be renamed
+ * @complete: Function to run on successful completion
  *
  * It's expected that valid references to the dentries and inodes are held
  */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d1bc0384ac95..f3ebabaa291d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -870,7 +870,6 @@ EXPORT_SYMBOL_GPL(nfs_request_add_commit_list_locked);
 /**
  * nfs_request_add_commit_list - add request to a commit list
  * @req: pointer to a struct nfs_page
- * @dst: commit list head
  * @cinfo: holds list lock and accounting info
  *
  * This sets the PG_CLEAN bit, updates the cinfo count of
-- 
2.20.1

