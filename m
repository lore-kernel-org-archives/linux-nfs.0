Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ares08.inai.de ([46.4.84.70]:52494 "EHLO ares08.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752053AbaJFV0x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Oct 2014 17:26:53 -0400
From: Jan Engelhardt <jengelh@inai.de>
To: steved@redhat.com
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] build: regenerate .pc file when .pc.in changed
Date: Mon,  6 Oct 2014 23:19:31 +0200
Message-Id: <1412630374-23246-3-git-send-email-jengelh@inai.de>
In-Reply-To: <1412630374-23246-1-git-send-email-jengelh@inai.de>
References: <1412630374-23246-1-git-send-email-jengelh@inai.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jan Engelhardt <jengelh@inai.de>
---
 Makefile.am | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Makefile.am b/Makefile.am
index 0832c1c..85f19c8 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -59,3 +59,4 @@ dist-hook:
 pkgconfigdir=$(libdir)/pkgconfig
 pkgconfig_DATA = libnfsidmap.pc
 
+$(pkgconfig_DATA): $(top_builddir)/config.status
-- 
2.0.0

