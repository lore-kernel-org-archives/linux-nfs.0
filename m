From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/4] utils/nfsd: fix -N optarg error printout
Date: Mon, 13 Apr 2009 11:29:11 +0300
Message-ID: <1239611351-21604-1-git-send-email-bhalevy@panasas.com>
References: <49E2F6E4.2080501@panasas.com>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:12150 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753348AbZDMI3V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 04:29:21 -0400
In-Reply-To: <49E2F6E4.2080501@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

as currently printed c is the version number, not a string char,
therefore is should be printed as %d not %c.  That said, just print
optarg as %s since it might be non-numeric.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 utils/nfsd/nfsd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index aaf8d29..c97c81f 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -86,7 +86,7 @@ main(int argc, char **argv)
 				NFSCTL_VERUNSET(versbits, c);
 				break;
 			default:
-				fprintf(stderr, "%c: Unsupported version\n", c);
+				fprintf(stderr, "%s: Unsupported version\n", optarg);
 				exit(1);
 			}
 			break;
-- 
1.6.2.1

