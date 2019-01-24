Return-Path: <SRS0=k36n=QA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F577C282C0
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 02:31:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 20F0C2184C
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 02:31:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726366AbfAXCbK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Jan 2019 21:31:10 -0500
Received: from mail.cn.fujitsu.com ([183.91.158.132]:45424 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726249AbfAXCbK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2019 21:31:10 -0500
X-IronPort-AV: E=Sophos;i="5.56,514,1539619200"; 
   d="scan'208";a="52695061"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 24 Jan 2019 10:31:08 +0800
Received: from G08CNEXCHPEKD03.g08.fujitsu.local (unknown [10.167.33.85])
        by cn.fujitsu.com (Postfix) with ESMTP id 528AD4BAD9DB;
        Thu, 24 Jan 2019 10:31:05 +0800 (CST)
Received: from ubuntu.g08.fujitsu.local (10.167.226.33) by
 G08CNEXCHPEKD03.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 24 Jan 2019 10:31:05 +0800
From:   Su Yanjun <suyj.fnst@cn.fujitsu.com>
To:     <mora@netapp.com>
CC:     <linux-nfs@vger.kernel.org>, Su Yanjun <suyj.fnst@cn.fujitsu.com>
Subject: [PATCH] CACHE: Fix test script as delegation being introduced
Date:   Wed, 23 Jan 2019 21:30:19 -0500
Message-ID: <1548297019-9398-1-git-send-email-suyj.fnst@cn.fujitsu.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.167.226.33]
X-yoursite-MailScanner-ID: 528AD4BAD9DB.A162B
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: suyj.fnst@cn.fujitsu.com
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When we run nfstest_cache with nfsversion=4, it fails.
As i know nfsv4 introduces delegation, so nfstest_cache runs fail since nfsv4.

The test commandline is as below:
 ./nfstest_cache --nfsversion=4 -e  /nfsroot --server 192.168.102.143 --client 192.168.102.142 --runtest acregmax_data --verbose all

This patch adds compatible code for nfsv3 and nfsv4.
When we test nfsv4, just use 'chmod' to recall delegation, then
run the test. As 'chmod' will modify atime, so use 'noatime' mount option.

Signed-off-by: Su Yanjun <suyj.fnst@cn.fujitsu.com>
---
 test/nfstest_cache | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/test/nfstest_cache b/test/nfstest_cache
index 0838418..a31d48f 100755
--- a/test/nfstest_cache
+++ b/test/nfstest_cache
@@ -165,8 +165,13 @@ class CacheTest(TestUtil):
             fd = None
             attr = 'data' if data_cache else 'attribute'
             header = "Verify consistency of %s caching with %s on a file" % (attr, self.nfsstr())
+
             # Mount options
-            mtopts = "hard,intr,rsize=4096,wsize=4096"
+            if self.nfsversion >= 4:
+                mtopts = "noatime,hard,intr,rsize=4096,wsize=4096"
+            else: 
+                mtopts = "hard,intr,rsize=4096,wsize=4096"
+
             if actimeo:
                 header += " actimeo = %d" % actimeo
                 mtopts += ",actimeo=%d" % actimeo
@@ -216,6 +221,11 @@ class CacheTest(TestUtil):
             if fstat.st_size != dlen:
                 raise Exception("Size of newly created file is %d, should have been %d" %(fstat.st_size, dlen))
 
+            if self.nfsversion >= 4:
+                # revoke delegation
+                self.dprint('DBG3', "revoke delegation")
+                self.clientobj.run_cmd('chmod +x %s' % self.absfile)
+
             if acregmax:
                 # Stat the unchanging file until acregmax is hit
                 # each stat doubles the valid cache time
-- 
2.7.4



