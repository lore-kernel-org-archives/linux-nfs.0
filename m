Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24143 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305Ab1EPOAI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 10:00:08 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 4/4] SQUASHME: remove unnecessary FIXME
Date: Mon, 16 May 2011 06:59:58 -0700
Message-Id: <1305554398-29235-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DCC715C.1090101@panasas.com>
References: <4DCC715C.1090101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/read.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 10eff1c..61e87c6 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -297,8 +297,6 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 	do {
 		int ret2;
 
-		/* FIXME: need a new layout segment? */
-
 		data = list_entry(list.next, struct nfs_read_data, pages);
 		list_del_init(&data->pages);
 
-- 
1.7.3.4

