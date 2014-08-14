Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:58772 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbaHNFcw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2014 01:32:52 -0400
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <srimalik@in.ibm.com>;
	Thu, 14 Aug 2014 11:02:49 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 141FC125802A
	for <linux-nfs@vger.kernel.org>; Thu, 14 Aug 2014 11:02:55 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s7E5Wt9x59703540
	for <linux-nfs@vger.kernel.org>; Thu, 14 Aug 2014 11:02:55 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7E5WVJ9018015
	for <linux-nfs@vger.kernel.org>; Thu, 14 Aug 2014 11:02:31 +0530
From: Srikrishan Malik <srimalik@in.ibm.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Srikrishan Malik <srimalik@in.ibm.com>
Subject: [PATCH] Fail the test if number of supported attrs are more than expected.
Date: Thu, 14 Aug 2014 11:02:26 +0530
Message-Id: <1407994346-18244-1-git-send-email-srimalik@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Srikrishan Malik <srimalik@in.ibm.com>
---
 nfs4.0/servertests/st_getattr.py |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/nfs4.0/servertests/st_getattr.py b/nfs4.0/servertests/st_getattr.py
index a55b923..6a4acdd 100644
--- a/nfs4.0/servertests/st_getattr.py
+++ b/nfs4.0/servertests/st_getattr.py
@@ -43,10 +43,14 @@ def _try_empty(t, c, path):
 def _try_supported(t, env, path):
     c = env.c1
     mandatory = sum([attr.mask for attr in env.attr_info if attr.mandatory])
+    all = sum([attr.mask for attr in env.attr_info])
     supported = c.supportedAttrs(path)
     if mandatory & supported != mandatory:
         t.fail("GETATTR(FATTR4_SUPPORTED_ATTRS) did not return "
                "all mandatory attributes")
+    if supported > all:
+        t.fail("GETATTR(FATTR4_SUPPORTED_ATTRS) returned more than expected "
+               "supported attributes for the protocol")
 
 def _try_long(env, path):
     c = env.c1
-- 
1.7.1

