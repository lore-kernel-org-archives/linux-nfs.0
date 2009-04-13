From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 4/4] utils/nfsd: enable/disable minorvers4 via command line
Date: Mon, 13 Apr 2009 11:29:42 +0300
Message-ID: <1239611382-21698-1-git-send-email-bhalevy@panasas.com>
References: <49E2F6E4.2080501@panasas.com>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:13801 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755471AbZDMI36 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 04:29:58 -0400
In-Reply-To: <49E2F6E4.2080501@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Extend -n/-N command line option syntax to accept <version>.<minorversion>
Only 4.1 is currently supported.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 utils/nfsd/nfsd.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 3d88b72..ce88989 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -51,6 +51,7 @@ main(int argc, char **argv)
 	int	count = 1, c, error, port, fd, found_one;
 	struct servent *ent;
 	struct hostent *hp;
+	char *p;
 
 	ent = getservbyname ("nfs", "udp");
 	if (ent != NULL)
@@ -81,8 +82,12 @@ main(int argc, char **argv)
 			}
 			break;
 		case 'n':
-			switch((c = atoi(optarg))) {
+			switch((c = strtol(optarg, &p, 0))) {
 			case 4:
+				if (*p == '.') {
+					minorvers4 = atoi(p + 1);
+					break;
+				}
 			case 3:
 			case 2:
 				NFSCTL_VERSET(versbits, c);
@@ -93,10 +98,14 @@ main(int argc, char **argv)
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

