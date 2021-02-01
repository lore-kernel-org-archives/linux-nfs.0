Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DF48C433E0
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Feb 2021 23:01:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5F5A364EAC
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Feb 2021 23:01:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229683AbhBAXB4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 1 Feb 2021 18:01:56 -0500
Received: from us-smtp-delivery-124.mimecast.com ([216.205.24.124]:60497 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S229999AbhBAXB4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2021 18:01:56 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1612220430;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=uZSW7djEK937bu1HiwRjVaL+nKWeIDAxQgERMuG6loA=;
        b=O5Fxh9F1h7BllMkm1BexHvAmM4nezOn3ukx7M9abo0j75veDJ+lHWYDJTeI6MXsn73O6ez
        yvFm04kfdHxLdhKOpAa+4oQe4XirQxhBRJowvn5gF0snHYljKlkTaLdy47w2OaEl3OmLUw
        Fdz79zSvkNVHHiK5Mh4N9R+C9Gh3vsg=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-89-uQJ56_pwPaCz-gXJ0ktdqg-1; Mon, 01 Feb 2021 18:00:23 -0500
X-MC-Unique: uQJ56_pwPaCz-gXJ0ktdqg-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 8B176107ACE3
        for <linux-nfs@vger.kernel.org>; Mon,  1 Feb 2021 23:00:22 +0000 (UTC)
Received: from madhat.home.dicksonnet.net (ovpn-114-86.phx2.redhat.com [10.3.114.86])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 4B68C60BF3
        for <linux-nfs@vger.kernel.org>; Mon,  1 Feb 2021 23:00:22 +0000 (UTC)
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] mountd: Cleanup how config options are read in
Date:   Mon,  1 Feb 2021 18:01:46 -0500
Message-Id: <20210201230147.45593-1-steved@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/mountd.c | 49 +++++++++++++++++++++++++------------------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 07bcdc5a..988e51c5 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -661,30 +661,17 @@ get_exportlist(void)
 	return elist;
 }
 
-int
-main(int argc, char **argv)
+int	vers;
+int	port = 0;
+int	descriptors = 0;
+
+inline static void 
+read_mount_conf(char **argv)
 {
-	char	*progname;
 	char	*s;
-	unsigned int listeners = 0;
-	int	foreground = 0;
-	int	port = 0;
-	int	descriptors = 0;
-	int	c;
-	int	vers;
-	struct sigaction sa;
-	struct rlimit rlim;
-
-	/* Set the basename */
-	if ((progname = strrchr(argv[0], '/')) != NULL)
-		progname++;
-	else
-		progname = argv[0];
-
-	/* Initialize logging. */
-	xlog_open(progname);
 
 	conf_init_file(NFS_CONFFILE);
+
 	xlog_from_conffile("mountd");
 	manage_gids = conf_get_bool("mountd", "manage-gids", manage_gids);
 	descriptors = conf_get_num("mountd", "descriptors", descriptors);
@@ -714,7 +701,29 @@ main(int argc, char **argv)
 		else
 			NFSCTL_VERUNSET(nfs_version, vers);
 	}
+}
+
+int
+main(int argc, char **argv)
+{
+	char	*progname;
+	unsigned int listeners = 0;
+	int	foreground = 0;
+	int	c;
+	struct sigaction sa;
+	struct rlimit rlim;
+
+	/* Set the basename */
+	if ((progname = strrchr(argv[0], '/')) != NULL)
+		progname++;
+	else
+		progname = argv[0];
+
+	/* Initialize logging. */
+	xlog_open(progname);
 
+	/* Read in config setting */
+	read_mount_conf(argv);
 
 	/* Parse the command line options and arguments. */
 	opterr = 0;
-- 
2.29.2

