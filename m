Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752724Ab3JXSQb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 14:16:31 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9OIGUka009258
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 24 Oct 2013 14:16:30 -0400
Received: from smallhat.boston.devel.redhat.com.org (vpn-62-59.rdu2.redhat.com [10.10.62.59])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r9OIGSR9030193
	for <linux-nfs@vger.kernel.org>; Thu, 24 Oct 2013 14:16:30 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] mountd: Deprecate the ability to disable TCP listeners.
Date: Thu, 24 Oct 2013 14:17:12 -0400
Message-Id: <1382638633-6710-3-git-send-email-steved@redhat.com>
In-Reply-To: <1382638633-6710-1-git-send-email-steved@redhat.com>
References: <1382638633-6710-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Disable the ability to turn off TCP listeners since that
is the protocol now required and best suited for
NFS traffic.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/mountd.c   | 11 +++++++----
 utils/mountd/mountd.man |  3 ---
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index f918472..b762301 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -755,7 +755,10 @@ main(int argc, char **argv)
 			nfs_version &= ~NFSVERSBIT(vers);
 			break;
 		case 'n':
-			NFSCTL_TCPUNSET(_rpcprotobits);
+			fprintf(stderr, 
+				"Deprecated: The -n flag (the ability to disable TCP listeners)" \
+				" is no longer supported\n");
+			usage(progname, 1);
 			break;
 		case 'r':
 			reverse_resolve = 1;
@@ -905,8 +908,8 @@ usage(const char *prog, int n)
 "Usage: %s [-F|--foreground] [-h|--help] [-v|--version] [-d kind|--debug kind]\n"
 "	[-o num|--descriptors num] [-f exports-file|--exports-file=file]\n"
 "	[-p|--port port] [-V version|--nfs-version version]\n"
-"	[-N version|--no-nfs-version version] [-n|--no-tcp]\n"
-"	[-H ha-callout-prog] [-s|--state-directory-path path]\n"
-"	[-g|--manage-gids] [-t num|--num-threads=num]\n", prog);
+"	[-N version|--no-nfs-version version] [-H ha-callout-prog]\n"
+"	[-s|--state-directory-path path][-g|--manage-gids] \n"
+"	[-t num|--num-threads=num]\n", prog);
 	exit(n);
 }
diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index b60dc90..c049e35 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -112,9 +112,6 @@ either one of these version should not be offered,
 must be invoked with the option
 .B "\-\-no-nfs-version <vers>" .
 .TP
-.B \-n " or " \-\-no-tcp
-Don't advertise TCP for mount.
-.TP
 .B \-P
 Ignored (compatibility with unfsd??).
 .TP
-- 
1.8.3.1

