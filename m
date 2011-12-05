Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34607 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356Ab1LEINA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 03:13:00 -0500
Received: by bkbzv3 with SMTP id zv3so1472947bkb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 00:12:58 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/10] use gcc
Date: Mon,  5 Dec 2011 10:12:53 +0200
Message-Id: <1323072773-17955-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDC7C4E.1040901@tonian.com>
References: <4EDC7C4E.1040901@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 Makefile |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index 14bb2ff..2b40126 100644
--- a/Makefile
+++ b/Makefile
@@ -1,8 +1,9 @@
+CC= gcc
 OBJS=	ctl.o efi.o
 CFLAGS= -I../../linux-pnfs.working/include
 
 ctl: $(OBJS)
-	cc -o ctl $(OBJS) -levent -lpthread -lparted
+	$(CC) -o ctl $(OBJS) -levent -lpthread -lparted
 
 clean:
 	rm -f $(OBJS) ctl
-- 
1.7.6

