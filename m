Return-Path: <SRS0=spLM=RR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DFB9C10F0B
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 21:12:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DA42521019
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 21:12:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727309AbfCNVML (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Mar 2019 17:12:11 -0400
Received: from mx1.redhat.com ([209.132.183.28]:53558 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727412AbfCNVML (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Mar 2019 17:12:11 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6128E307E04C;
        Thu, 14 Mar 2019 21:12:11 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-19.rdu2.redhat.com [10.10.122.19])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2EA3C60BE6;
        Thu, 14 Mar 2019 21:12:10 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 8CF63213FE; Thu, 14 Mar 2019 17:12:10 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [pynfs PATCH 4/4] nfs4.1: test delayed reclaim following a server reboot
Date:   Thu, 14 Mar 2019 17:12:10 -0400
Message-Id: <20190314211210.7454-5-smayhew@redhat.com>
In-Reply-To: <20190314211210.7454-1-smayhew@redhat.com>
References: <20190314211210.7454-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 14 Mar 2019 21:12:11 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

REBT5 tests a server reboot where the client begins reclaim shortly
before the end of the grace period.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs4.1/server41tests/st_reboot.py | 56 +++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

diff --git a/nfs4.1/server41tests/st_reboot.py b/nfs4.1/server41tests/st_reboot.py
index 06913f8..b77e2cf 100644
--- a/nfs4.1/server41tests/st_reboot.py
+++ b/nfs4.1/server41tests/st_reboot.py
@@ -283,3 +283,59 @@ def testRebootWithManyManyManyClientsDoubleReclaim(t, env):
     CODE: REBT4c
     """
     return doTestRebootWithNClients(t, env, 1000, double_reclaim=True)
+
+def testRebootWithLateReclaim(t, env):
+    """Reboot with client that starts reclaim near end of grace
+
+    FLAGS: reboot
+    CODE: REBT5
+    """
+    boot_time = int(time.time())
+    lease_time = 90
+    fh = []
+    stateid = []
+    name = "%s_client" % env.testname(t)
+    owner = "owner_%s" % name
+    c = env.c1.new_client(name)
+    sess = c.create_session()
+    reclaim_complete(sess)
+    N = 42
+    for i in range(N):
+        path = sess.c.homedir + ["%s_file_%i" % (owner, i)]
+        tmpfh, tmpstateid = create_confirm(sess, owner, path)
+        fh.append(tmpfh)
+    lease_time = _getleasetime(sess)
+    boot_time = _waitForReboot(env)
+    try:
+        sleep_time = lease_time - 5
+        env.sleep(sleep_time, "Delaying start of reclaim")
+        res = sess.compound([])
+        check(res, NFS4ERR_BADSESSION, "Bare sequence after reboot")
+        res = create_session(c)
+        check(res, NFS4ERR_STALE_CLIENTID, "Reclaim using old clientid")
+        c = env.c1.new_client(name)
+        sess = c.create_session()
+        lease_time = _getleasetime(sess)
+        # Reclaim open files, with a short delay between each open reclaim.
+        # This should put us at the end of the original grace period.  The
+        # server might keep extending the grace period by 1 second (up to
+        # an additional lease period in total) as long as we keep reclaming.
+        for i in range(N):
+            res = open_file(sess, owner, path=fh[i], claim_type=CLAIM_PREVIOUS,
+                           access=OPEN4_SHARE_ACCESS_BOTH,
+                           deny=OPEN4_SHARE_DENY_NONE,
+                           deleg_type=OPEN_DELEGATE_NONE)
+            check(res, msg="Reclaim using newly created clientid")
+            tmpstateid = res.resarray[-2].stateid
+            stateid.append(tmpstateid)
+            time.sleep(0.25)
+        reclaim_complete(sess)
+        for i in range(N):
+            close_file(sess, fh[i], stateid[i])
+    except:
+        grace_end_time = boot_time + lease_time + 5
+        now = int(time.time())
+        if now < grace_end_time:
+            sleep_time = grace_end_time - now
+            env.sleep(sleep_time, "Waiting for grace period to end")
+        raise
-- 
2.17.2

