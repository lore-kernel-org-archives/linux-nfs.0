Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:43648 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756670Ab3AUUso (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:48:44 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 13/13] nfs:  Allow up to 5000 NFSv4 connections (instead of 1024).
Date: Mon, 21 Jan 2013 12:45:59 -0800
Message-Id: <1358801159-18829-14-git-send-email-greearb@candelatech.com>
In-Reply-To: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
References: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 fs/nfs/callback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 5088b57..ceed971 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -335,7 +335,7 @@ static struct svc_serv *nfs_callback_create_svc(int minorversion)
 	/* As there is only one thread we need to over-ride the
 	 * default maximum of 80 connections
 	 */
-	serv->sv_maxconn = 1024;
+	serv->sv_maxconn = 5000;
 	dprintk("nfs_callback_create_svc: service created\n");
 	return serv;
 }
-- 
1.7.3.4

