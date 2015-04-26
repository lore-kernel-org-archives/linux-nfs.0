Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47101 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbDZPtQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Apr 2015 11:49:16 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: [PATCH 1/2] nfsd/blocklayout: pretend we can send deviceid notifications
Date: Sun, 26 Apr 2015 17:48:06 +0200
Message-Id: <1430063287-13621-2-git-send-email-hch@lst.de>
In-Reply-To: <1430063287-13621-1-git-send-email-hch@lst.de>
References: <1430063287-13621-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit df52699e4fcef ("NFSv4.1: Don't cache deviceids that have no
notifications") causes the Linux NFS client stop caching deviceid
unless a server pretends to support deviceid notifications.  While
this behavior is stupid and the language around this area in rfc5661
is a mess carified by an errata that I submittted, Trond insists
on this behavior.  Not caching deviceids degrades block layout
performance massively as a GETDEVICEINFO is fairly expensive.

So add this hack to make the Linux client happy again.

Cc: stable@vger.kernel.org
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/blocklayout.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index 03d647b..58298fa6 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -181,6 +181,16 @@ nfsd4_block_proc_layoutcommit(struct inode *inode,
 }
 
 const struct nfsd4_layout_ops bl_layout_ops = {
+	/*
+	 * Pretend that we send notification to the client.  This is a blatant
+	 * lie to force recent Linux clients to cache our device IDs.
+	 * We rarely ever change the device ID, so the harm of leaking deviceids
+	 * for a while isn't too bad.  Unfortunately RFC5661 is a complete mess
+	 * in this regard, but I filed errata 4119 for this a while ago, and
+	 * hopefully the Linux client will eventually start caching deviceids
+	 * without this again.
+	 */
+	.notify_types		= NOTIFY_DEVICEID4_DELETE,
 	.proc_getdeviceinfo	= nfsd4_block_proc_getdeviceinfo,
 	.encode_getdeviceinfo	= nfsd4_block_encode_getdeviceinfo,
 	.proc_layoutget		= nfsd4_block_proc_layoutget,
-- 
1.9.1

