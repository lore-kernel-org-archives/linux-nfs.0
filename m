From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 03/21] SQUASHME: nfsd41: disable support for minorversion by default
Date: Fri,  3 Apr 2009 01:37:41 +0300
Message-ID: <1238711861-22115-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25328 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764632AbZDBWhu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:37:50 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use user mode nfs-utils (rpc.nfsd option) to enable.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfssvc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 097dc55..1f26d9f 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -121,7 +121,7 @@ struct svc_program		nfsd_program = {
 
 };
 
-u32 nfsd_supported_minorversion = NFSD_SUPPORTED_MINOR_VERSION;
+u32 nfsd_supported_minorversion;
 
 int nfsd_vers(int vers, enum vers_op change)
 {
-- 
1.6.2.1

