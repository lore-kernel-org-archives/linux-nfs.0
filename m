Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:32983 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603Ab1EPBKj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 May 2011 21:10:39 -0400
Date: Mon, 16 May 2011 11:10:30 +1000
From: NeilBrown <neilb@suse.de>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] Declare modalias for nfs4filelayout to support auto-loading
 of modules.
Message-ID: <20110516111030.55ca84b0@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi,
 I had a brief look at configuring pnfs recently and wondered why 

   http://wiki.linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions

suggested that the layout module should be explicitly 'modprobe'd when that
sort of thing is normally automatic.
pnfs.c makes the appropriate 'request-module' call, but there is no
MODULE_ALIAS to link the relevant module with the requested name.

This patch adds the required MODULE_ALIAS.  It has only been compile-tested
(my interest is as yet only theoretical :-)

Thanks,
NeilBrown


>From 1f87c7a913fd7d4caf8b464761e44d109512aad6 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Mon, 16 May 2011 10:55:57 +1000
Subject: [PATCH] Declare modalias for nfs4filelayout to support auto-loading of modules.

pnfs.c uses 'request_module' with the name
   nfs-layouttype4-1

when it actually wants
   nfs4filelayout

so give the latter a "MODULE_ALIAS" so it can be found with the former
name.

This avoids needing to add an alais to /etc/modprobe.d/...

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/nfs4filelayout.c |    1 +
 fs/nfs/pnfs.h           |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index be79dc9..86c2f5f 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -873,6 +873,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.read_pagelist		= filelayout_read_pagelist,
 	.write_pagelist		= filelayout_write_pagelist,
 };
+NFSV4_LAYOUT_MODULE_ALIAS(LAYOUT_NFSV4_1_FILES);
 
 static int __init nfs4filelayout_init(void)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 0c015ba..1c2a1f1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -55,6 +55,8 @@ enum pnfs_try_status {
 #ifdef CONFIG_NFS_V4_1
 
 #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
+#define NFSV4_LAYOUT_MODULE_ALIAS(id) \
+	MODULE_ALIAS(LAYOUT_NFSV4_1_MODULE_PREFIX "-" #id)
 
 enum {
 	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
-- 
1.7.3.4

