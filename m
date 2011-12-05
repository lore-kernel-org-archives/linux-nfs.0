Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34607 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931Ab1LEIOH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 03:14:07 -0500
Received: by mail-bw0-f46.google.com with SMTP id zv3so1472947bkb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 00:14:06 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/10] ctl: fix compiler warnings
Date: Mon,  5 Dec 2011 10:14:01 +0200
Message-Id: <1323072841-18376-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDC7C4E.1040901@tonian.com>
References: <4EDC7C4E.1040901@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 ctl.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/ctl.c b/ctl.c
index d989ab8..e5d16e3 100644
--- a/ctl.c
+++ b/ctl.c
@@ -75,11 +75,10 @@ struct event	ge;
 int
 main(int argc, char **argv)
 {
-	int		upcall_fd,
-			operation	= -1,
-			len;
-	char		c,
-			*prog;
+	int		upcall_fd;
+	int		operation = -1;
+	char		c;
+	char		*prog;
 	pthread_t	t;
 	void		*thr_val;
 
@@ -162,7 +161,7 @@ process_msg(int fd, short ev_type, void *arg)
 		return;
 	len = sizeof (bl_comm_res_t);
 	if ((cc = read(fd, &msg, sizeof (msg))) != sizeof (msg)) {
-		printf("Failed to get all of message. Got %d, expected %d\n",
+		printf("Failed to get all of message. Got %d, expected %Zd\n",
 		    cc, sizeof (msg));
 		resp->res_status = PNFS_BLOCK_FAILURE;
 		write(fd, resp, len);
@@ -352,9 +351,7 @@ get_dm(bl_comm_msg_t *msg, bl_comm_res_t *res, int *lenp)
 bl_comm_res_t *
 check_dm(bl_comm_msg_t *msg, bl_comm_res_t *res, int *len)
 {
-	int	fd,
-		major,
-		minor;
+	int	major, minor;
 	char	*name;
 	
 	res->res_status = PNFS_BLOCK_SUCCESS;
@@ -391,7 +388,7 @@ get_slice(bl_comm_msg_t *msg, bl_comm_res_t *res, int *len)
 	partition = minor & 0xf;
 	res->res_status = PNFS_BLOCK_FAILURE;	// Default condition
 	
-	printf("%s: %u:%u: ", __func__, major, minor); fflush(stdout);
+	printf("%s: %u:%u: ", __func__, (unsigned)major, (unsigned)minor); fflush(stdout);
 
 	if (mknod(path, S_IFBLK | 0600, dev)) {
 		perror("mknod");
@@ -421,7 +418,8 @@ get_slice(bl_comm_msg_t *msg, bl_comm_res_t *res, int *len)
 	res->res_status = PNFS_BLOCK_SUCCESS;
 	res->u.slice.start = ppart->geom.start;
 	res->u.slice.length = ppart->geom.length;
-	printf("Dev: %d:%d, Start: %llu, Length: %llu\n", major, minor,
+	printf("Dev: %u:%u, Start: %llu, Length: %llu\n",
+	       (unsigned)major, (unsigned)minor,
 	       res->u.slice.start, res->u.slice.length);
 out:
 	(void) unlink(path);
-- 
1.7.6

