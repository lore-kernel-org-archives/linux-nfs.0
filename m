Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E14CC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 14:09:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 499332192D
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 14:09:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391914AbfBOOJJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 09:09:09 -0500
Received: from mx1.redhat.com ([209.132.183.28]:28088 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389389AbfBOOJJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 09:09:09 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6089D12E394
        for <linux-nfs@vger.kernel.org>; Fri, 15 Feb 2019 14:09:09 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-117-166.phx2.redhat.com [10.3.117.166])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 1AF6E17D38
        for <linux-nfs@vger.kernel.org>; Fri, 15 Feb 2019 14:09:09 +0000 (UTC)
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] sm-notify: Added -f flag to nfs.conf parsing
Date:   Fri, 15 Feb 2019 09:09:07 -0500
Message-Id: <20190215140907.15272-1-steved@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 15 Feb 2019 14:09:09 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Cleaned up the nfs.conf parsing and added the setting
of the force to the nfs.conf parsing

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 nfs.conf                |  1 +
 utils/statd/sm-notify.c | 33 +++++++++++++++++++++------------
 2 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/nfs.conf b/nfs.conf
index 722b024..f1ebfdb 100644
--- a/nfs.conf
+++ b/nfs.conf
@@ -65,6 +65,7 @@
 #
 [sm-notify]
 # debug=0
+# force=0
 # retry-time=900
 # outgoing-port=
 # outgoing-addr=
diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 29dad38..4b6a3a7 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -49,6 +49,7 @@
 #define NLM_END_GRACE_FILE	"/proc/fs/lockd/nlm_end_grace"
 
 int lift_grace = 1;
+int force = 0;
 
 struct nsm_host {
 	struct nsm_host *	next;
@@ -480,19 +481,10 @@ nsm_lift_grace_period(void)
 	close(fd);
 	return;
 }
-
-int
-main(int argc, char **argv)
+inline static void 
+read_nfs_conf(char **argv)
 {
-	int	c, sock, force = 0;
-	char *	progname;
-	char *	s;
-
-	progname = strrchr(argv[0], '/');
-	if (progname != NULL)
-		progname++;
-	else
-		progname = argv[0];
+	char *s;
 
 	conf_init_file(NFS_CONFFILE);
 	xlog_from_conffile("sm-notify");
@@ -500,10 +492,27 @@ main(int argc, char **argv)
 	opt_srcport = conf_get_str("sm-notify", "outgoing-port");
 	opt_srcaddr = conf_get_str("sm-notify", "outgoing-addr");
 	lift_grace = conf_get_bool("sm-notify", "lift-grace", lift_grace);
+
 	s = conf_get_str("statd", "state-directory-path");
 	if (s && !nsm_setup_pathnames(argv[0], s))
 		exit(1);
 	opt_update_state = conf_get_bool("sm-notify", "update-state", opt_update_state);
+	force = conf_get_bool("sm-notify", "force", force);
+}
+
+int
+main(int argc, char **argv)
+{
+	int	c, sock;
+	char *	progname;
+
+	progname = strrchr(argv[0], '/');
+	if (progname != NULL)
+		progname++;
+	else
+		progname = argv[0];
+
+	read_nfs_conf(argv);
 
 	while ((c = getopt(argc, argv, "dm:np:v:P:f")) != -1) {
 		switch (c) {
-- 
2.20.1

