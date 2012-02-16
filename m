Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42443 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445Ab2BPSRJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 13:17:09 -0500
Received: by eaah12 with SMTP id h12so968126eaa.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:17:07 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 1/5] 4.1 server tests: testReadDeleg recognize also OPEN_DELEGATE_NONE_EXT
Date: Thu, 16 Feb 2012 20:17:04 +0200
Message-Id: <1329416224-21108-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4F3D47B3.1090708@tonian.com>
References: <4F3D47B3.1090708@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fail test if server returned no delegation, even when giving a valid reason.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 nfs4.1/server41tests/st_open.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index 895916a..c64a7ef 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -141,7 +141,7 @@ def testReadDeleg(t, env):
     check(res)
     fh = res.resarray[-1].object
     deleg = res.resarray[-2].delegation
-    if deleg.delegation_type == OPEN_DELEGATE_NONE:
+    if deleg.delegation_type == OPEN_DELEGATE_NONE or deleg.delegation_type == OPEN_DELEGATE_NONE_EXT:
         fail("Could not get delegation")
     # c2 - OPEN - WRITE
     sess2 = env.c1.new_client_session("%s_2" % env.testname(t))
-- 
1.7.6.5

