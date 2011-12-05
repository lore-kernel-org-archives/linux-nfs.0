Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34607 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab1LEINW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 03:13:22 -0500
Received: by mail-bw0-f46.google.com with SMTP id zv3so1472947bkb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 00:13:21 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/10] ctl: improve debug printouts
Date: Mon,  5 Dec 2011 10:13:16 +0200
Message-Id: <1323072796-18106-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDC7C4E.1040901@tonian.com>
References: <4EDC7C4E.1040901@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 ctl.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/ctl.c b/ctl.c
index 2071b0e..959ef6a 100644
--- a/ctl.c
+++ b/ctl.c
@@ -176,6 +176,7 @@ process_msg(int fd, short ev_type, void *arg)
 		resp->res_status = PNFS_BLOCK_FAILURE;
 	} else {
 		printf("Processing: %s: ", table[msg.msg_type].msg_name);
+		fflush(stdout);
 		resp = table[msg.msg_type].msg_func(&msg, resp, &len);
 	}
 
@@ -215,6 +216,8 @@ get_sig(bl_comm_msg_t *msg, bl_comm_res_t *res, int *lenp)
 	minor = msg->u.msg_dev & 0xfffff;
 	dev = (major << 8) | (minor & ~0xf);
 
+	printf("%s: %d:%d: ", __func__, major, minor);
+	fflush(stdout);
 	res->res_status = PNFS_BLOCK_FAILURE;	// Default condition
 	
 	if (mknod(path, S_IFBLK | 0600, dev)) {
@@ -386,6 +389,8 @@ get_slice(bl_comm_msg_t *msg, bl_comm_res_t *res, int *len)
 	partition = minor & 0xf;
 	res->res_status = PNFS_BLOCK_FAILURE;	// Default condition
 	
+	printf("%s: %u:%u: ", __func__, major, minor); fflush(stdout);
+
 	if (mknod(path, S_IFBLK | 0600, dev)) {
 		perror("mknod");
 		goto out;
-- 
1.7.6

