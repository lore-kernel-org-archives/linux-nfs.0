Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34607 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500Ab1LEINd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 03:13:33 -0500
Received: by mail-bw0-f46.google.com with SMTP id zv3so1472947bkb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 00:13:32 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/10] increase compiler warning level
Date: Mon,  5 Dec 2011 10:13:27 +0200
Message-Id: <1323072807-18175-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDC7C4E.1040901@tonian.com>
References: <4EDC7C4E.1040901@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index 2b40126..df074dd 100644
--- a/Makefile
+++ b/Makefile
@@ -1,6 +1,6 @@
 CC= gcc
 OBJS=	ctl.o efi.o
-CFLAGS= -I../../linux-pnfs.working/include
+CFLAGS= -I../../linux-pnfs.working/include -Wall
 
 ctl: $(OBJS)
 	$(CC) -o ctl $(OBJS) -levent -lpthread -lparted
-- 
1.7.6

