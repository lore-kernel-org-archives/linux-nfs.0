Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36175 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933AbaARQtZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Jan 2014 11:49:25 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0IGnO9R004042
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 18 Jan 2014 11:49:24 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-60-134.rdu2.redhat.com [10.10.60.134])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s0IGnORY019253
	for <linux-nfs@vger.kernel.org>; Sat, 18 Jan 2014 11:49:24 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] rpc.statd: Allow usage messages to be displayed when statd is running.
Date: Sat, 18 Jan 2014 11:51:15 -0500
Message-Id: <1390063875-11456-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/statd/statd.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 8c51bcc..8f31111 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -238,12 +238,6 @@ int main (int argc, char **argv)
 	/* Set hostname */
 	MY_NAME = NULL;
 
-	/* Refuse to start if another statd is running */
-	if (nfs_probe_statd()) {
-		fprintf(stderr, "Statd service already running!\n");
-		exit(1);
-	}
-
 	/* Process command line switches */
 	while ((arg = getopt_long(argc, argv, "h?vVFNH:dn:p:o:P:L", longopts, NULL)) != EOF) {
 		switch (arg) {
@@ -306,6 +300,12 @@ int main (int argc, char **argv)
 		}
 	}
 
+	/* Refuse to start if another statd is running */
+	if (nfs_probe_statd()) {
+		fprintf(stderr, "Statd service already running!\n");
+		exit(1);
+	}
+
 	if (port == out_port && port != 0) {
 		fprintf(stderr, "Listening and outgoing ports cannot be the same!\n");
 		exit(-1);
-- 
1.8.3.1

