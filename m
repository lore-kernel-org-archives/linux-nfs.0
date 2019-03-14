Return-Path: <SRS0=spLM=RR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCFB3C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 21:12:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8CF7921019
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 21:12:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727760AbfCNVML (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Mar 2019 17:12:11 -0400
Received: from mx1.redhat.com ([209.132.183.28]:59552 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727467AbfCNVML (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Mar 2019 17:12:11 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6176381DFC;
        Thu, 14 Mar 2019 21:12:11 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-19.rdu2.redhat.com [10.10.122.19])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2AB885C231;
        Thu, 14 Mar 2019 21:12:10 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 84395213FC; Thu, 14 Mar 2019 17:12:10 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [pynfs PATCH 2/4] nfs4.1: add some more reboot tests
Date:   Thu, 14 Mar 2019 17:12:08 -0400
Message-Id: <20190314211210.7454-3-smayhew@redhat.com>
In-Reply-To: <20190314211210.7454-1-smayhew@redhat.com>
References: <20190314211210.7454-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 14 Mar 2019 21:12:11 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

REBT3a, REBT3b, and REBT3c test recovery with multiple clients following
a server reboot, where the server reboots again during the grace period
while clients are still reclaiming.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs4.1/server41tests/st_reboot.py | 31 ++++++++++++++++++++++++++++++-
 1 file changed, 30 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/server41tests/st_reboot.py b/nfs4.1/server41tests/st_reboot.py
index 0216127..8bce9ec 100644
--- a/nfs4.1/server41tests/st_reboot.py
+++ b/nfs4.1/server41tests/st_reboot.py
@@ -149,7 +149,7 @@ def doTestAllClientsNoGrace(t, env, states):
             log.warn("server took approximately %d seconds to lift grace "
                         "after all clients reclaimed" % lift_time)
 
-def doTestRebootWithNClients(t, env, n=10):
+def doTestRebootWithNClients(t, env, n=10, double_reboot=False):
     boot_time = int(time.time())
     lease_time = 90
     states = []
@@ -166,6 +166,11 @@ def doTestRebootWithNClients(t, env, n=10):
     boot_time = _waitForReboot(env)
 
     try:
+        if double_reboot:
+            for i in range(n/2):
+                lease_time = doTestOneClientGrace(t, env, states[i])
+            boot_time = _waitForReboot(env)
+
         for i in range(n):
             lease_time = doTestOneClientGrace(t, env, states[i])
 
@@ -210,3 +215,27 @@ def testRebootWithManyManyManyClients(t, env):
     CODE: REBT2c
     """
     return doTestRebootWithNClients(t, env, 1000)
+
+def testDoubleRebootWithManyClients(t, env):
+    """Double reboot with many clients
+
+    FLAGS: reboot
+    CODE: REBT3a
+    """
+    return doTestRebootWithNClients(t, env, double_reboot=True)
+
+def testDoubleRebootWithManyManyClients(t, env):
+    """Double reboot with many many clients
+
+    FLAGS: reboot
+    CODE: REBT3b
+    """
+    return doTestRebootWithNClients(t, env, 100, True)
+
+def testDoubleRebootWithManyManyManyClients(t, env):
+    """Double reboot with many many many clients
+
+    FLAGS: reboot
+    CODE: REBT3c
+    """
+    return doTestRebootWithNClients(t, env, 1000, True)
-- 
2.17.2

