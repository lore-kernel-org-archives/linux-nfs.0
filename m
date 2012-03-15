Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p02c11o143.mxlogic.net ([208.65.144.76]:47801 "EHLO
	p02c11o143.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754597Ab2COSDN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Mar 2012 14:03:13 -0400
From: Peter Staubach <pstaubach@exagrid.com>
To: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 15 Mar 2012 14:01:31 -0400
Subject: RE: [PATCH 1/1] nfsd: Warn when no servers are specified on the
 command line
Message-ID: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC062D5C800D@IT-1874.Isys.com>
References: <1331832223-20737-1-git-send-email-steved@redhat.com>
In-Reply-To: <1331832223-20737-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I am curious why such a message is required?  Isn't the reason for having a default is so that the option does not need to specified?

	Thanx...

		ps


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Steve Dickson
Sent: Thursday, March 15, 2012 1:24 PM
To: Linux NFS Mailing list
Subject: [PATCH 1/1] nfsd: Warn when no servers are specified on the command line

When the number of servers are not specified on the command, log a warning message that the default number of services will be started

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsd/nfsd.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c index 8bc5d3a..c744ee1 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -188,6 +188,8 @@ main(int argc, char **argv)
 		}
 	}
 
+	xlog_open(progname);
+
 	if (optind < argc) {
 		if ((count = atoi(argv[optind])) < 0) {
 			/* insane # of servers */
@@ -203,10 +205,11 @@ main(int argc, char **argv)
 			socket_up = 1;
 			goto set_threads;
 		}
+	} else {
+		xlog(L_WARNING, "No server number specified. '%d' nfsd will be started",
+			count);
 	}
 
-	xlog_open(progname);
-
 	nfsd_enable_protos(&proto4, &proto6);
 
 	if (!NFSCTL_TCPISSET(protobits)) {
--
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
