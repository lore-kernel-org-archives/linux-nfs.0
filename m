Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EB9DC43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:57:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 768F2206B8
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:57:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727095AbfCDQ5Z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 11:57:25 -0500
Received: from mx1.redhat.com ([209.132.183.28]:35982 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726063AbfCDQ5Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Mar 2019 11:57:25 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 75181BDFF
        for <linux-nfs@vger.kernel.org>; Mon,  4 Mar 2019 16:57:25 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-116-96.phx2.redhat.com [10.3.116.96])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2EE291001DCE
        for <linux-nfs@vger.kernel.org>; Mon,  4 Mar 2019 16:57:25 +0000 (UTC)
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Add nfs.conf equivalent for the statd --no-notify cmdline option
Date:   Mon,  4 Mar 2019 11:57:23 -0500
Message-Id: <20190304165723.24097-1-steved@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 04 Mar 2019 16:57:25 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Justin Mitchell <jumitche@redhat.com>

Also cleaned up how nfs.conf is read.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 nfs.conf            |  1 +
 utils/statd/statd.c | 55 ++++++++++++++++++++++++++++-----------------
 2 files changed, 36 insertions(+), 20 deletions(-)

diff --git a/nfs.conf b/nfs.conf
index f1ebfdb..d332375 100644
--- a/nfs.conf
+++ b/nfs.conf
@@ -62,6 +62,7 @@
 # name=
 # state-directory-path=/var/lib/nfs/statd
 # ha-callout=
+# no-notify=0
 #
 [sm-notify]
 # debug=0
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 2cc6cf3..1467380 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -238,6 +238,39 @@ static void set_nlm_port(char *type, int port)
 		fprintf(stderr, "%s: failed to open %s: %s\n", 
 			name_p, pathbuf, strerror(errno));
 }
+int port = 0, out_port = 0;
+int nlm_udp = 0, nlm_tcp = 0;
+
+inline static void 
+read_nfsconf(char **argv)
+{
+	char *s;
+
+	conf_init_file(NFS_CONFFILE);
+	xlog_from_conffile("statd");
+
+	out_port = conf_get_num("statd", "outgoing-port", out_port);
+	port = conf_get_num("statd", "port", port);
+
+	MY_NAME = conf_get_str("statd", "name");
+	if (MY_NAME)
+		run_mode |= STATIC_HOSTNAME;
+
+	s = conf_get_str("statd", "state-directory-path");
+	if (s && !nsm_setup_pathnames(argv[0], s))
+		exit(1);
+
+	s = conf_get_str("statd", "ha-callout");
+	if (s)
+		ha_callout_prog = s;
+
+	nlm_tcp = conf_get_num("lockd", "port", nlm_tcp);
+	/* udp defaults to the same as tcp ! */
+	nlm_udp = conf_get_num("lockd", "udp-port", nlm_tcp);
+
+	if (conf_get_bool("statd", "no-notify", false))
+		run_mode |= MODE_NO_NOTIFY;
+}
 
 /*
  * Entry routine/main loop.
@@ -245,11 +278,8 @@ static void set_nlm_port(char *type, int port)
 int main (int argc, char **argv)
 {
 	extern char *optarg;
-	char *s;
 	int pid;
 	int arg;
-	int port = 0, out_port = 0;
-	int nlm_udp = 0, nlm_tcp = 0;
 	struct rlimit rlim;
 	int notify_sockfd;
 	char *env;
@@ -275,23 +305,8 @@ int main (int argc, char **argv)
 	/* Set hostname */
 	MY_NAME = NULL;
 
-	conf_init_file(NFS_CONFFILE);
-	xlog_from_conffile("statd");
-	out_port = conf_get_num("statd", "outgoing-port", out_port);
-	port = conf_get_num("statd", "port", port);
-	MY_NAME = conf_get_str("statd", "name");
-	if (MY_NAME)
-		run_mode |= STATIC_HOSTNAME;
-	s = conf_get_str("statd", "state-directory-path");
-	if (s && !nsm_setup_pathnames(argv[0], s))
-		exit(1);
-	s = conf_get_str("statd", "ha-callout");
-	if (s)
-		ha_callout_prog = s;
-
-	nlm_tcp = conf_get_num("lockd", "port", nlm_tcp);
-	/* udp defaults to the same as tcp ! */
-	nlm_udp = conf_get_num("lockd", "udp-port", nlm_tcp);
+	/* Read nfs.conf */
+	read_nfsconf(argv);
 
 	/* Process command line switches */
 	while ((arg = getopt_long(argc, argv, "h?vVFNH:dn:p:o:P:LT:U:", longopts, NULL)) != EOF) {
-- 
2.20.1

