Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f44.google.com ([209.85.128.44]:38871 "EHLO
	mail-qe0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab3IZSnC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:43:02 -0400
Received: by mail-qe0-f44.google.com with SMTP id 3so1111709qeb.17
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:43:02 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 45/49] nfs: resolve compile dependency in nfs_xdr.h
Date: Thu, 26 Sep 2013 14:42:59 -0400
Message-Id: <1380220979-14761-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Include headers in nfs_xdr.h required for
struct rpc_task, nfs4_verifier, nfs4_stateid

Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[add more includes needed since v3.4-rc]
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 include/linux/nfs_xdr.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 01fd84b..93cbda7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -3,6 +3,10 @@
 
 #include <linux/nfsacl.h>
 #include <linux/sunrpc/gss_api.h>
+#include <linux/nfs.h>
+#include <linux/nfs3.h>
+#include <linux/nfs4.h>
+#include <linux/sunrpc/sched.h>
 
 /*
  * To change the maximum rsize and wsize supported by the NFS client, adjust
-- 
1.8.3.1

