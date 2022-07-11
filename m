Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3219C43334
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Jul 2022 19:55:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231300AbiGKTzf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Jul 2022 15:55:35 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54874 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229759AbiGKTzf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2022 15:55:35 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5630B550A8
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2022 12:55:34 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id DE8EE615E3
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2022 19:55:33 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2FEF0C34115;
        Mon, 11 Jul 2022 19:55:33 +0000 (UTC)
Subject: [PATCH v1] Add basic tests for DESTROY_SESSION
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 11 Jul 2022 15:55:32 -0400
Message-ID: <165756921593.2281287.10609723157095539123.stgit@morisot.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The existing DSESS tests seem specific to Ganesha; they fail when
run against Linux NFSD. Here's a basic one that all server
implementations should PASS.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 nfs4.1/server41tests/st_destroy_session.py |   23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/server41tests/st_destroy_session.py b/nfs4.1/server41tests/st_destroy_session.py
index b8be62582366..bd5e12d7ebf1 100644
--- a/nfs4.1/server41tests/st_destroy_session.py
+++ b/nfs4.1/server41tests/st_destroy_session.py
@@ -1,12 +1,33 @@
 from .st_create_session import create_session
 from xdrdef.nfs4_const import *
-from .environment import check, fail, create_file, open_file
+from .environment import check, fail, create_file, open_file, close_file
 from xdrdef.nfs4_type import open_owner4, openflag4, createhow4, open_claim4
 import nfs_ops
 op = nfs_ops.NFS4ops()
 import threading
 import rpc.rpc as rpc
 
+def testDestroyBasic(t, env):
+    """Operations after DESTROY_SESSION should fail with BADSESSION
+
+    FLAGS: destroy_session all
+    CODE: DSESS1
+    """
+    c = env.c1.new_client(env.testname(t))
+    sess1 = c.create_session()
+    sess1.compound([op.reclaim_complete(FALSE)])
+    res = c.c.compound([op.destroy_session(sess1.sessionid)])
+    res = create_file(sess1, env.testname(t),
+                      access=OPEN4_SHARE_ACCESS_READ)
+    check(res, NFS4ERR_BADSESSION)
+    sess2 = c.create_session()
+    res = create_file(sess2, env.testname(t),
+                      access=OPEN4_SHARE_ACCESS_READ)
+    check(res)
+    fh = res.resarray[-1].object
+    open_stateid = res.resarray[-2].stateid
+    close_file(sess2, fh, stateid=open_stateid)
+
 def testDestroy(t, env):
     """
    - create a session


