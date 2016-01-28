Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:37061 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbcA1Wjk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jan 2016 17:39:40 -0500
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 28 Jan 2016 15:39:40 -0700
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C79EB3E4003F
	for <linux-nfs@vger.kernel.org>; Thu, 28 Jan 2016 15:39:36 -0700 (MST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0SMdadg34209806
	for <linux-nfs@vger.kernel.org>; Thu, 28 Jan 2016 22:39:36 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0SMdZPx005678
	for <linux-nfs@vger.kernel.org>; Thu, 28 Jan 2016 17:39:35 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com, Malahal Naineni <malahal@us.ibm.com>
Subject: [PATCH] Ignore whitespace at the beginning of option tags
Date: Thu, 28 Jan 2016 16:38:47 -0600
Message-Id: <1454020727-1814-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following should work now:

[General]
	Domain = local.domain.edu

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 cfg.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/cfg.c b/cfg.c
index c615d24..e0ab839 100644
--- a/cfg.c
+++ b/cfg.c
@@ -210,6 +210,7 @@ static void
 conf_parse_line (int trans, char *line, size_t sz)
 {
   char *val;
+  char *tag;
   size_t i;
   int j;
   static char *section = 0;
@@ -262,8 +263,14 @@ conf_parse_line (int trans, char *line, size_t sz)
 	/* Skip trailing whitespace, if any */
 	for (j = sz - (val - line) - 1; j > 0 && isspace (val[j]); j--)
 	  val[j] = '\0';
+
+	/* Skip beginning white space */
+	tag = line;
+	while (isspace(*tag))
+		tag++;
+
 	/* XXX Perhaps should we not ignore errors?  */
-	conf_set (trans, section, line, val, 0, 0);
+	conf_set (trans, section, tag, val, 0, 0);
 	return;
       }
 
-- 
1.8.3.1

