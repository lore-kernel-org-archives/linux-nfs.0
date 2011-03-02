Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:50123 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab1CEJ1y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Mar 2011 04:27:54 -0500
From: bookjovi@gmail.com
To: bookjovi@gmail.com
Cc: Trond Myklebust <Trond.Myklebust@netapp.com> (maintainer:NFS,
	SUNRPC, AND...),
        linux-nfs@vger.kernel.org (open list:NFS, SUNRPC, AND...),
        linux-kernel@vger.kernel.org (open list)
Subject: [PATCH] nfs: fix compilation warning
Date: Wed,  2 Mar 2011 18:19:37 -0500
Message-Id: <1299107978-3248-1-git-send-email-bookjovi@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Jovi Zhang <bookjovi@gmail.com>

this commit fix compilation warning as following:
linux-2.6/fs/nfs/nfs4proc.c:3265: warning: comparison of distinct pointer types lacks a cast

Signed-off-by: Jovi Zhang <bookjovi@gmail.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1ff76ac..c7eb4ee 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3262,7 +3262,7 @@ static int buf_to_pages_noslab(const void *buf, size_t buflen,
 	spages = pages;
 
 	do {
-		len = min(PAGE_CACHE_SIZE, buflen);
+		len = min((size_t)PAGE_CACHE_SIZE, buflen);
 		newpage = alloc_page(GFP_KERNEL);
 
 		if (newpage == NULL)
-- 
1.7.2.3

