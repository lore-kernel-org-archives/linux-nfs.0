Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60605 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755556Ab2JVQGy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 12:06:54 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3828544iea.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 09:06:54 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/10] rpc.gssd: Squelch compiler warning
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Oct 2012 12:06:52 -0400
Message-ID: <20121022160652.4552.84836.stgit@lebasque.1015granger.net>
In-Reply-To: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gss_util.c: At top level:
gss_util.c:98:36: warning: ISO C does not allow extra ‘;’ outside of a
function [-pedantic]

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/gss_util.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/gss_util.c b/utils/gssd/gss_util.c
index 0e327b0..2e6d40f 100644
--- a/utils/gssd/gss_util.c
+++ b/utils/gssd/gss_util.c
@@ -95,7 +95,7 @@
 /* Global gssd_credentials handle */
 gss_cred_id_t gssd_creds;
 
-gss_OID g_mechOid = GSS_C_NULL_OID;;
+gss_OID g_mechOid = GSS_C_NULL_OID;
 
 #if 0
 static void

