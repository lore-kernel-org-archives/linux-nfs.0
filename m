Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36535 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754042Ab1FNVCD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:02:03 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/8] nfs_xdr: Move nfs4_string definition out of #ifdef CONFIG_NFS_V4
Date: Tue, 14 Jun 2011 17:02:01 -0400
Message-Id: <1308085321-12485-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7CA2F.7030407@panasas.com>
References: <4DF7CA2F.7030407@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

exofs file system wants to use pnfs_osd_xdr.h file instead of
redefining pnfs-objects types in it's private "pnfs.h" headr.

Before we do the switch we must make sure pnfs_osd_xdr.h is
compilable also under NFS versions smaller than 4.1. Since now
it is needed regardless of version, by the exofs code.

nfs4_string is not the only nfs4 type out in the global scope.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/nfs_xdr.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0a21844..7372921 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -774,6 +774,11 @@ struct nfs3_getaclres {
 	struct posix_acl *	acl_default;
 };
 
+struct nfs4_string {
+	unsigned int len;
+	char *data;
+};
+
 #ifdef CONFIG_NFS_V4
 
 typedef u64 clientid4;
@@ -964,11 +969,6 @@ struct nfs4_server_caps_res {
 	struct nfs4_sequence_res	seq_res;
 };
 
-struct nfs4_string {
-	unsigned int len;
-	char *data;
-};
-
 #define NFS4_PATHNAME_MAXCOMPONENTS 512
 struct nfs4_pathname {
 	unsigned int ncomponents;
-- 
1.7.3.4

