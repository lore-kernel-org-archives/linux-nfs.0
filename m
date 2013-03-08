Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f173.google.com ([209.85.210.173]:55049 "EHLO
	mail-ia0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929Ab3CHTqX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 14:46:23 -0500
Received: by mail-ia0-f173.google.com with SMTP id h37so1839048iak.4
        for <linux-nfs@vger.kernel.org>; Fri, 08 Mar 2013 11:46:23 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/11] mountd: make local functions in v4root.c static
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 08 Mar 2013 14:46:21 -0500
Message-ID: <20130308194621.5656.84272.stgit@seurat.1015granger.net>
In-Reply-To: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
References: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.  set_pseudofs_security() and pseudofs_update() have no
call sites outside of v4root.c, and there are no header declarations
for either function.  Define both as static.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/v4root.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index 726b50d..34d098a 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -55,7 +55,8 @@ static nfs_export pseudo_root = {
 	.m_warned = 0,
 };
 
-void set_pseudofs_security(struct exportent *pseudo, struct exportent *source)
+static void
+set_pseudofs_security(struct exportent *pseudo, struct exportent *source)
 {
 	struct sec_entry *se;
 	int i;
@@ -121,7 +122,8 @@ v4root_support(void)
 	return 0;
 }
 
-int pseudofs_update(char *hostname, char *path, nfs_export *source)
+static int
+pseudofs_update(char *hostname, char *path, nfs_export *source)
 {
 	nfs_export *exp;
 

