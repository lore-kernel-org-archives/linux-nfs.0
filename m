Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:63272 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079Ab1BVQHf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 11:07:35 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id 1D70F1858
	for <linux-nfs@vger.kernel.org>; Tue, 22 Feb 2011 17:07:28 +0100 (MET)
Received: from adserv71.win.desy.de (adserv71.win.desy.de [131.169.97.57])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 174BA13E89
	for <linux-nfs@vger.kernel.org>; Tue, 22 Feb 2011 17:07:27 +0100 (MET)
Received: from smtp-intra-2.desy.de (lb-40-26.desy.de) by adserv71.win.desy.de
 (Clearswift SMTPRS 5.3.4) with ESMTP id <T9b5abfc3fb83a96139dd4@adserv71.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Tue, 22 Feb 2011 17:07:27 +0100
Received: from ADXV1.win.desy.de (adxb11.win.desy.de [131.169.97.62])
	by smtp-intra-2.desy.de (DESY-INTRA-2) with ESMTP id 4883DE32
	for <linux-nfs@vger.kernel.org>; Tue, 22 Feb 2011 17:07:27 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfsd: fix missing include
Date: Tue, 22 Feb 2011 17:08:43 +0100
Message-Id: <1298390923-6547-1-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I got some compile time error:

  CC [M]  fs/nfsd/nfs4proc.o
In file included from include/linux/nfsd/nfsd4_pnfs.h:39:0,
                 from include/linux/nfsd/nfs4layoutxdr.h:38,
                 from fs/nfsd/nfs4proc.c:37:
include/linux/nfs_xdr.h:1124:15: error: field ‘refcount’ has incomplete type

and here is my attempt to fix it
---
 include/linux/nfs_xdr.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a965f9d..e4710b0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -5,6 +5,7 @@
 #include <linux/nfs3.h>
 #include <linux/nfs4.h>
 #include <linux/sunrpc/sched.h>
+#include <linux/kref.h>
 
 /*
  * To change the maximum rsize and wsize supported by the NFS client, adjust
-- 
1.7.4

