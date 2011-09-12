Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:47586 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939Ab1ILWGe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 18:06:34 -0400
Received: by yie30 with SMTP id 30so3089705yie.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2011 15:06:34 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/8] nfsumount: Squelch compiler warning
To: linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 18:06:32 -0400
Message-ID: <20110912220632.10854.1269.stgit@matisse.1015granger.net>
In-Reply-To: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
References: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

nfsumount.c: In function ‘nfs_umount_is_vers4’:
nfsumount.c:164: warning: conversion to ‘int’ from ‘size_t’ may alter its value
nfsumount.c:173: warning: conversion to ‘size_t’ from ‘int’ may change the sign of the result

Introduced by commit 3564ebbf.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index b846564..3538d88 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -161,7 +161,8 @@ static int nfs_umount_is_vers4(const struct mntentchn *mc)
 		goto not_found;
 
 	do {
-		int nlen = strlen(pmc->m.mnt_fsname);
+		size_t nlen = strlen(pmc->m.mnt_fsname);
+
 		/*
 		 * It's possible the mount location string in /proc/mounts
 		 * ends with a '/'. In this case, if the entry came from

