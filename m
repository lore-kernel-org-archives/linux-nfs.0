Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:40435 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751717Ab1KNPDp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 10:03:45 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RPy21-0007vp-3z
	for linux-nfs@vger.kernel.org; Mon, 14 Nov 2011 10:01:11 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] rpc.idmapd: Sections in idmapd.conf are ignored.
Date: Mon, 14 Nov 2011 10:03:40 -0500
Message-Id: <1321283020-15730-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the parsing routine, conf_parse_line(), a string
is not being null terminated which is causing
section of the config file to be ignored.

https://bugzilla.linux-nfs.org/show_bug.cgi?id=205

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/conffile.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index fa0dc6b..3990578 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -256,13 +256,14 @@ conf_parse_line(int trans, char *line, size_t sz)
 			val++, j++;
 		if (*val)
 			i = j;
-		section = malloc(i);
+		section = malloc(i+1);
 		if (!section) {
 			xlog_warn("conf_parse_line: %d: malloc (%lu) failed", ln,
 						(unsigned long)i);
 			return;
 		}
 		strncpy(section, line, i);
+		section[i] = '\0';
 
 		if (arg) 
 			free(arg);
-- 
1.7.7

