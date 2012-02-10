Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30164 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760275Ab2BJWCd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:33 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 21/21] NFS: Export v4.1 symbols back to nfs.ko
Date: Fri, 10 Feb 2012 17:02:05 -0500
Message-Id: <1328911325-1566-21-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

pnfs is buried too deep in the generic client to make it easy to
separate out.  Instead, I just export the symbols back so when
CONFIG_V4_1 is selected nfs.ko will depend on nfs4.ko

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile   |    2 +-
 fs/nfs/nfs4proc.c |    1 +
 fs/nfs/pnfs.c     |    5 +++++
 3 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index c356cda..863bf85 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,7 +9,6 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
@@ -24,6 +23,7 @@ obj-$(CONFIG_NFS_V4) += nfs4.o
 nfs4-y = nfs4super.o nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 	 delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
 	 nfs4namespace.o dns_resolve.o nfs4client.o nfs4getroot.o
+nfs4-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs4-$(CONFIG_SYSCTL) += nfs4sysctl.o
 
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3ae8485..1cb940b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -631,6 +631,7 @@ out:
 	dprintk("<-- %s status=%d\n", __func__, ret);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs4_setup_sequence);
 
 struct nfs41_call_sync_data {
 	const struct nfs_server *seq_server;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f7edc4a..ef2053f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -84,6 +84,7 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
 	}
 	nfss->pnfs_curr_ld = NULL;
 }
+EXPORT_SYMBOL_GPL(unset_pnfs_layoutdriver);
 
 /*
  * Try to set the server's pnfs module to the pnfs layout type specified by id.
@@ -135,6 +136,7 @@ out_no_driver:
 	dprintk("%s: Using NFSv4 I/O\n", __func__);
 	server->pnfs_curr_ld = NULL;
 }
+EXPORT_SYMBOL_GPL(set_pnfs_layoutdriver);
 
 int
 pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
@@ -1141,6 +1143,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 	nfs_pageio_init(pgio, inode, ld->pg_read_ops, server->rsize, 0);
 	return true;
 }
+EXPORT_SYMBOL_GPL(pnfs_pageio_init_read);
 
 bool
 pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags)
@@ -1153,6 +1156,7 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode,
 	nfs_pageio_init(pgio, inode, ld->pg_write_ops, server->wsize, ioflags);
 	return true;
 }
+EXPORT_SYMBOL_GPL(pnfs_pageio_init_write);
 
 bool
 pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
@@ -1567,3 +1571,4 @@ out_free:
 	kfree(data);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(pnfs_layoutcommit_inode);
-- 
1.7.9

