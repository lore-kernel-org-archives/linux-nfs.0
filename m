Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34607 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab1LEIO3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 03:14:29 -0500
Received: by mail-bw0-f46.google.com with SMTP id zv3so1472947bkb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 00:14:29 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/10] ctl: main should return 0 on success
Date: Mon,  5 Dec 2011 10:14:24 +0200
Message-Id: <1323072864-18516-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDC7C4E.1040901@tonian.com>
References: <4EDC7C4E.1040901@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 ctl.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/ctl.c b/ctl.c
index f1d878d..a28c9e9 100644
--- a/ctl.c
+++ b/ctl.c
@@ -131,6 +131,8 @@ main(int argc, char **argv)
 		close(upcall_fd);
 		pthread_join(t, &thr_val);
 	}
+
+	return 0;
 }
 
 /*
-- 
1.7.6

