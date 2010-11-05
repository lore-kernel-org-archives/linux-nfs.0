Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57520 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752670Ab0KECmc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 22:42:32 -0400
Message-ID: <4CD36FE7.1010100@cn.fujitsu.com>
Date: Fri, 05 Nov 2010 10:45:59 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: SteveD@redhat.com
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: [PATCH] libnfs.a: fix a bug when parse section's arg
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When parsing section's arg at configure file, the pointer 
should stop when fetch ']', and give the warning message.

---
 support/nfs/conffile.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 24640f4..798e5f3 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -271,9 +271,9 @@ conf_parse_line(int trans, char *line, size_t sz)
 		if (ptr == NULL)
 			return;
 		line = ++ptr;
-		while (*ptr && *ptr != '"')
+		while (*ptr && *ptr != '"' && *ptr != ']')
 			ptr++;
-		if (*ptr == '\0') {
+		if (*ptr == '\0' || *ptr == ']') {
 			xlog_warn("config file error: line %d: "
  				"non-matched '\"', ignoring until next section", ln);
 		}  else {
-- 
1.7.0.1


