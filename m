Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f42.google.com ([209.85.215.42]:61805 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbaHFGZS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 02:25:18 -0400
Received: by mail-la0-f42.google.com with SMTP id pv20so1572303lab.15
        for <linux-nfs@vger.kernel.org>; Tue, 05 Aug 2014 23:25:16 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH v2 03/11] configure.ac: enable GNU_SOURCE for stat64/statfs64
Date: Wed,  6 Aug 2014 08:24:58 +0200
Message-Id: <1407306306-29796-4-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
References: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use AC_USE_SYSTEM_EXTENSIONS to enable GNU_SOURCE, which is needed
for:
 - stat64 in utils/exportfs/exportfs.c
 - statfs64 in utils/mountd/cache.c

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 configure.ac | 1 +
 1 file changed, 1 insertion(+)

diff --git a/configure.ac b/configure.ac
index 408f4c8..b9682ed 100644
--- a/configure.ac
+++ b/configure.ac
@@ -8,6 +8,7 @@ AM_INIT_AUTOMAKE
 AC_PREREQ(2.59)
 AC_PREFIX_DEFAULT(/usr)
 AM_MAINTAINER_MODE
+AC_USE_SYSTEM_EXTENSIONS
 
 dnl *************************************************************
 dnl * Define the set of applicable options
-- 
2.0.4

