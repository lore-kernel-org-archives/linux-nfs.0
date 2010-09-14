Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49989 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752540Ab0INC7i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Sep 2010 22:59:38 -0400
Message-ID: <4C8EE506.1020509@cn.fujitsu.com>
Date: Tue, 14 Sep 2010 10:59:18 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: steved@redhat.com
CC: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] rpc.idmapd: Type of idmap client should be defined by ic_id
 not ic_clid.
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The type of idmap_client is defined by idmap_client.ic_id for nfs,
so nfsd should have the same style.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 utils/idmapd/idmapd.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 9ecab66..b76607a 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -119,8 +119,8 @@ struct idmap_client {
 static struct idmap_client nfsd_ic[2] = {
 {
 	.ic_which = IC_IDNAME, 
-	.ic_clid = "Server", 
-	.ic_id = "", 
+	.ic_clid = "", 
+	.ic_id = "Server", 
 	.ic_path = IC_IDNAME_CHAN, 
 	.ic_fd = -1, 
 	.ic_dirfd = -1, 
@@ -128,8 +128,8 @@ static struct idmap_client nfsd_ic[2] = {
 },
 {
 	.ic_which = IC_NAMEID, 
-	.ic_clid = "Server", 
-	.ic_id = "", 
+	.ic_clid = "", 
+	.ic_id = "Server", 
 	.ic_path = IC_NAMEID_CHAN, 
 	.ic_fd = -1, 
 	.ic_dirfd = -1, 
-- 
1.6.5.2



-- 
Regards
Bian Naimeng

