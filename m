Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.alpinelinux.org ([74.117.189.114]:48724 "EHLO
	mail.alpinelinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbaLPIit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 03:38:49 -0500
From: Natanael Copa <ncopa@alpinelinux.org>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 7/9] Include string.h for memset
Date: Tue, 16 Dec 2014 09:28:58 +0100
Message-Id: <1418718540-13667-8-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
References: <1418718540-13667-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes warning: implicit declaration of function 'memset'

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 src/authgss_prot.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/authgss_prot.c b/src/authgss_prot.c
index 669eab7..d80ba17 100644
--- a/src/authgss_prot.c
+++ b/src/authgss_prot.c
@@ -37,6 +37,7 @@
 #include <stdio.h>
 #include <stdlib.h>
 #include <stdarg.h>
+#include <string.h>
 #include <rpc/types.h>
 #include <rpc/xdr.h>
 #include <rpc/auth.h>
-- 
2.2.0

