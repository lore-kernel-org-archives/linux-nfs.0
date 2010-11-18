Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:34150 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755876Ab0KRKgs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 05:36:48 -0500
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id oAIAak0E022877
	for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 16:06:46 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAIAakbx3989578
	for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 16:06:46 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAIAajaF020476
	for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 21:36:45 +1100
Date: Thu, 18 Nov 2010 16:06:43 +0530
From: Arun R Bharadwaj <arun@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: ffilz@us.ibm.com, jlayton@redhat.com
Subject: [PATCH][BUG]: Pure nfs client performance using odirect.
Message-ID: <20101118103643.GA13235@linux.vnet.ibm.com>
Reply-To: arun@linux.vnet.ibm.com
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Pure nfs client performance using odirect.

When an application opens a file with O_DIRECT flag, if the size of
the data that is written is equal to wsize, the client sends a
WRITE RPC with stable flag set to UNSTABLE followed by a single
COMMIT RPC rather than sending a single WRITE RPC with the stable
flag set to FILE_SYNC. This a bug.

Patch to fix this.

Signed-off-by: Arun R Bharadwaj <arun@linux.vnet.ibm.com>

Index: linux-2.6.36-rc7/fs/nfs/direct.c
===================================================================
--- linux-2.6.36-rc7.orig/fs/nfs/direct.c	2010-11-18 15:53:15.904972002 +0530
+++ linux-2.6.36-rc7/fs/nfs/direct.c	2010-11-18 15:54:01.184972001 +0530
@@ -867,7 +867,7 @@
 		goto out;
 	nfs_alloc_commit_data(dreq);
 
-	if (dreq->commit_data == NULL || count < wsize)
+	if (dreq->commit_data == NULL || count <= wsize)
 		sync = NFS_FILE_SYNC;
 
 	dreq->inode = inode;
