Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60142 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757640Ab2EAPpy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 11:45:54 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/6] nfsd: state.c should include current_stateid.h
Date: Tue,  1 May 2012 11:45:44 -0400
Message-Id: <1335887149-30420-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1335887149-30420-1-git-send-email-bfields@redhat.com>
References: <1335887149-30420-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

OK, admittedly I'm mainly just trying to shut sparse up.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 14251a2..307dd9c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -42,6 +42,7 @@
 #include <linux/sunrpc/clnt.h>
 #include "xdr4.h"
 #include "vfs.h"
+#include "current_stateid.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
-- 
1.7.9.5

