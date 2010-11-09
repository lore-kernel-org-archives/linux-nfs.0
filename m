Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55304 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753875Ab0KIBee (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Nov 2010 20:34:34 -0500
Message-ID: <4CD8A5CF.4050007@cn.fujitsu.com>
Date: Tue, 09 Nov 2010 09:37:19 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: SteveD@redhat.com
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] libnfs.a: fix a bug when parse section's arg
References: <4CD36FE7.1010100@cn.fujitsu.com>
In-Reply-To: <4CD36FE7.1010100@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When parsing section's arg at configure file, the pointer 
should stop when fetch ']', and give the warning message.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
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
-- 1.7.0.1 

