Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752776AbbLIQBo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Dec 2015 11:01:44 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 83FDCB5937
	for <linux-nfs@vger.kernel.org>; Wed,  9 Dec 2015 16:01:44 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-236-249.phx2.redhat.com [10.3.236.249])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tB9G1haE016486
	for <linux-nfs@vger.kernel.org>; Wed, 9 Dec 2015 11:01:44 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] rpc.idmapd: Added a usage routine
Date: Wed,  9 Dec 2015 11:01:41 -0500
Message-Id: <1449676902-19575-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Show the correct arguments when invalid
arguments are used.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/idmapd/idmapd.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 689608a..910b02e 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -199,6 +199,12 @@ flush_nfsd_idmap_cache(void)
 	return ret;
 }
 
+void usage(char *progname)
+{
+	fprintf(stderr, "Usage: %s [-fvCS] [-p path] [-c path]\n",
+		basename(progname));
+}
+
 int
 main(int argc, char **argv)
 {
@@ -232,9 +238,11 @@ main(int argc, char **argv)
 			conf_path = optarg;
 		if (opt == '?') {
 			if (strchr(GETOPTSTR, optopt))
-				errx(1, "'-%c' option requires an argument.", optopt);
+				warnx("'-%c' option requires an argument.", optopt);
 			else
-				errx(1, "'-%c' is an invalid argument.", optopt);
+				warnx("'-%c' is an invalid argument.", optopt);
+			usage(progname);
+			exit(1);
 		}
 	}
 	optind = 1;
-- 
2.4.3

