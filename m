Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from resqmta-ch2-11v.sys.comcast.net ([69.252.207.43]:52362 "EHLO
        resqmta-ch2-11v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750837AbdGENdK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jul 2017 09:33:10 -0400
From: Joshua Kinard <kumba@gentoo.org>
Subject: [PATCH] Fix struct rpcent for uclibc-ng
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Natanael Copa <ncopa@alpinelinux.org>,
        Joshua Kinard <kumba@gentoo.org>
Message-ID: <229cb44f-f79e-f704-5930-9b1decacf555@gentoo.org>
Date: Wed, 5 Jul 2017 09:24:49 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 6d8d4b5a7bf6 addresses an issue for musl, based on a description of
an earlier patch at https://patchwork.kernel.org/patch/5499671/.  That
description notes uncertainty with uclibc, which also defines __GLIBC__.
This patch fixes the uclibc case by also checking for __UCLIBC__.

Fixes: 6d8d4b5a7bf6 ("Include string.h for memset")
Signed-off-by: Joshua Kinard <kumba@gentoo.org>
Cc: Natanael Copa <ncopa@alpinelinux.org>
---

 tirpc/rpc/rpcent.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tirpc/rpc/rpcent.h b/tirpc/rpc/rpcent.h
index e07503c..9d3ef9c 100644
--- a/tirpc/rpc/rpcent.h
+++ b/tirpc/rpc/rpcent.h
@@ -49,7 +49,7 @@ extern "C" {
 #endif
 
 /* These are defined in /usr/include/rpc/netdb.h */
-#if !defined(__GLIBC__)
+#if !defined(__GLIBC__) || defined(__UCLIBC__)
 struct rpcent {
 	char	*r_name;	/* name of server for this rpc program */
 	char	**r_aliases;	/* alias list */

