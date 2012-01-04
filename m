Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35483 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab2ADT5J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 14:57:09 -0500
Received: by mail-vx0-f174.google.com with SMTP id fk14so13490667vcb.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jan 2012 11:57:09 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] mountd: remove newline from xlog() format specifier
 strings
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 04 Jan 2012 14:57:07 -0500
Message-ID: <20120104195707.21904.17223.stgit@degas.1015granger.net>
In-Reply-To: <20120104194136.21904.36616.stgit@degas.1015granger.net>
References: <20120104194136.21904.36616.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: xlog() already adds a newline to the end of each line of
output.  Remove the superfluous newline from a number of xlog()
call sites in mountd.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/fsloc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/utils/mountd/fsloc.c b/utils/mountd/fsloc.c
index e2add2d..704b7a0 100644
--- a/utils/mountd/fsloc.c
+++ b/utils/mountd/fsloc.c
@@ -40,12 +40,12 @@ static void replicas_print(struct servers *sp)
 {
 	int i;
 	if (!sp) {
-		xlog(L_NOTICE, "NULL replicas pointer\n");
+		xlog(L_NOTICE, "NULL replicas pointer");
 		return;
 	}
-	xlog(L_NOTICE, "replicas listsize=%i\n", sp->h_num);
+	xlog(L_NOTICE, "replicas listsize=%i", sp->h_num);
 	for (i=0; i<sp->h_num; i++) {
-		xlog(L_NOTICE, "    %s:%s\n",
+		xlog(L_NOTICE, "    %s:%s",
 		       sp->h_mp[i]->h_host, sp->h_mp[i]->h_path);
 	}
 }
@@ -125,13 +125,13 @@ static struct servers *method_list(char *data)
 	int i, listsize;
 	struct servers *rv=NULL;
 
-	xlog(L_NOTICE, "method_list(%s)\n", data);
+	xlog(L_NOTICE, "method_list(%s)", data);
 	for (ptr--, listsize=1; ptr; ptr=index(ptr, ':'), listsize++)
 		ptr++;
 	list = malloc(listsize * sizeof(char *));
 	copy = strdup(data);
 	if (copy)
-		xlog(L_NOTICE, "converted to %s\n", copy);
+		xlog(L_NOTICE, "converted to %s", copy);
 	if (list && copy) {
 		ptr = copy;
 		for (i=0; i<listsize; i++) {

