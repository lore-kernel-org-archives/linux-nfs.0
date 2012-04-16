Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:41076 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab2DPQHH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Apr 2012 12:07:07 -0400
Received: by yhmm54 with SMTP id m54so2527551yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 16 Apr 2012 09:07:07 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: include cld.h in the headers_install target
Date: Mon, 16 Apr 2012 12:07:02 -0400
Message-Id: <1334592422-26567-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The cld.h file contains the definition of the upcall format to talk
with nfsdcld. When I added the file though, I neglected to add it
to the headers-y target, so make headers_install wasn't installing it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/nfsd/Kbuild |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfsd/Kbuild b/include/linux/nfsd/Kbuild
index b8d4001..5b7d84a 100644
--- a/include/linux/nfsd/Kbuild
+++ b/include/linux/nfsd/Kbuild
@@ -1,3 +1,4 @@
+header-y += cld.h
 header-y += debug.h
 header-y += export.h
 header-y += nfsfh.h
-- 
1.7.7.6

