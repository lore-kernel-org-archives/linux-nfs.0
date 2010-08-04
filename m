From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 07/24] Removed warnings from fsloc.c
Date: Wed,  4 Aug 2010 11:12:03 -0400
Message-ID: <1280934740-11366-8-git-send-email-steved@redhat.com>
References: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:54506 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752730Ab0HDPMY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:12:24 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdm-0002SZ-KJ
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:22 -0400
In-Reply-To: <1280934740-11366-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fsloc.c: In function 'replicas_lookup':
fsloc.c:149: warning: unused parameter 'key'

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/cache.c |    2 +-
 utils/mountd/fsloc.c |    2 +-
 utils/mountd/fsloc.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index bf18a9a..5488056 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -600,7 +600,7 @@ static void write_fsloc(FILE *f, struct exportent *ep, char *path)
 	if (ep->e_fslocmethod == FSLOC_NONE)
 		return;
 
-	servers = replicas_lookup(ep->e_fslocmethod, ep->e_fslocdata, path);
+	servers = replicas_lookup(ep->e_fslocmethod, ep->e_fslocdata);
 	if (!servers)
 		return;
 	qword_print(f, "fsloc");
diff --git a/utils/mountd/fsloc.c b/utils/mountd/fsloc.c
index 5b094b0..e2add2d 100644
--- a/utils/mountd/fsloc.c
+++ b/utils/mountd/fsloc.c
@@ -146,7 +146,7 @@ static struct servers *method_list(char *data)
 }
 
 /* Returns appropriately filled struct servers, or NULL if had a problem */
-struct servers *replicas_lookup(int method, char *data, char *key)
+struct servers *replicas_lookup(int method, char *data)
 {
 	struct servers *sp=NULL;
 	switch(method) {
diff --git a/utils/mountd/fsloc.h b/utils/mountd/fsloc.h
index 8296d1c..1605df4 100644
--- a/utils/mountd/fsloc.h
+++ b/utils/mountd/fsloc.h
@@ -44,7 +44,7 @@ struct servers {
 	int h_referral;		/* 0=replica, 1=referral */
 };
 
-struct servers *replicas_lookup(int method, char *data, char *key);
+struct servers *replicas_lookup(int method, char *data);
 void release_replicas(struct servers *server);
 
 #endif /* FSLOC_H */
-- 
1.7.2

