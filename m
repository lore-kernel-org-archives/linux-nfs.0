From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/3] utils/nfsd: enable nfs minorvers4 by default
Date: Wed, 22 Apr 2009 15:10:39 +0300
Message-ID: <1240402239-31824-1-git-send-email-bhalevy@panasas.com>
References: <49EF0846.5030800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Chuck Lever <chuck.lever@oracle.com>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2341 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752239AbZDVMLD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 08:11:03 -0400
In-Reply-To: <49EF0846.5030800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Enable support for the maximum minor version (4.1 at the moment)
by default.  It can be disabled using the -N command line
option.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 utils/nfsd/nfsd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index bd23d9d..e3c0094 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -41,7 +41,7 @@ static struct option longopts[] =
 };
 unsigned int protobits = NFSCTL_ALLBITS;
 unsigned int versbits = NFSCTL_ALLBITS;
-int minorvers4;				/* nfsv4 minor version */
+int minorvers4 = NFSD_MAXMINORVERS4;		/* nfsv4 minor version */
 char *haddr = NULL;
 
 int
-- 
1.6.2.1

