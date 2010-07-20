From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 24/24] Removed warnings from configfile.c
Date: Tue, 20 Jul 2010 19:37:37 -0400
Message-ID: <1279669057-17509-25-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60388 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761912Ab0GUAn0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:43:26 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNZ-0004K5-JL
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:41 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

configfile.c:195: warning: 'inline' is not at beginning of declaration
configfile.c:232: warning: 'inline' is not at beginning of declaration

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/configfile.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 5cff009..3f3b249 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -192,7 +192,7 @@ void free_all(void)
 	}
 }
 static char *versions[] = {"v2", "v3", "v4", "vers", "nfsvers", NULL};
-int inline check_vers(char *mopt, char *field)
+inline int check_vers(char *mopt, char *field)
 {
 	int i, found=0;
 
@@ -229,7 +229,7 @@ extern sa_family_t config_default_family;
  * If so, set the appropriate global value which will 
  * be used as the initial value in the server negation.
  */
-int inline default_value(char *mopt)
+inline int default_value(char *mopt)
 {
 	struct mount_options *options = NULL;
 	int dftlen = strlen("default");
-- 
1.7.0.1

