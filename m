From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/3] utils/nfsd: disable minorvers4 via command line
Date: Wed, 22 Apr 2009 15:10:19 +0300
Message-ID: <1240402219-31791-1-git-send-email-bhalevy@panasas.com>
References: <49EF0846.5030800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Chuck Lever <chuck.lever@oracle.com>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30616 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751646AbZDVMKk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 08:10:40 -0400
In-Reply-To: <49EF0846.5030800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Extend -N command line option syntax to accept <version>.<minorversion>
to disable support for <minorversion>.
Only 4.1 is currently supported.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 utils/nfsd/nfsd.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index ac264da..bd23d9d 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -50,6 +50,7 @@ main(int argc, char **argv)
 	int	count = 1, c, error, port, fd, found_one;
 	struct servent *ent;
 	struct hostent *hp;
+	char *p;
 
 	ent = getservbyname ("nfs", "udp");
 	if (ent != NULL)
@@ -80,10 +81,14 @@ main(int argc, char **argv)
 			}
 			break;
 		case 'N':
-			switch((c = atoi(optarg))) {
-			case 2:
-			case 3:
+			switch((c = strtol(optarg, &p, 0))) {
 			case 4:
+				if (*p == '.') {
+					minorvers4 = -atoi(p + 1);
+					break;
+				}
+			case 3:
+			case 2:
 				NFSCTL_VERUNSET(versbits, c);
 				break;
 			default:
-- 
1.6.2.1

