Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60605 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755547Ab2JVQHN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 12:07:13 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3828544iea.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 09:07:12 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/10] rpc.gssd: Squelch compiler error
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Oct 2012 12:07:11 -0400
Message-ID: <20121022160711.4552.45963.stgit@lebasque.1015granger.net>
In-Reply-To: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gssd_proc.c: In function ‘handle_krb5_upcall’:
gssd_proc.c:1117:2: warning: ISO C forbids ‘return’ with expression, in
function returning void [-pedantic]

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/gssd_proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 1bc3942..ec251fa 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -1116,7 +1116,7 @@ handle_krb5_upcall(struct clnt_info *clp)
 		return;
 	}
 
-	return process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL);
+	process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL);
 }
 
 void

