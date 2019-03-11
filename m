Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BE10C10F0B
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:49:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5931A2075C
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:49:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727531AbfCKPtw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Mar 2019 11:49:52 -0400
Received: from mx1.redhat.com ([209.132.183.28]:58952 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727480AbfCKPtw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Mar 2019 11:49:52 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C9572307D846;
        Mon, 11 Mar 2019 15:49:51 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-19.rdu2.redhat.com [10.10.122.19])
        by smtp.corp.redhat.com (Postfix) with ESMTP id B0DD05DA62;
        Mon, 11 Mar 2019 15:49:51 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 4209A21508; Mon, 11 Mar 2019 11:49:51 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Subject: [pynfs PATCH 3/3] nfs4.1: close the file created in SEQ10b
Date:   Mon, 11 Mar 2019 11:49:51 -0400
Message-Id: <20190311154951.6144-4-smayhew@redhat.com>
In-Reply-To: <20190311154951.6144-1-smayhew@redhat.com>
References: <20190311154951.6144-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 11 Mar 2019 15:49:51 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Otherwise, the DESTROY_CLIENTID sent during cleanup returns
NFS4ERR_CLIENTID_BUSY.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs4.1/server41tests/st_sequence.py | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
index 391b226..c21d8f7 100644
--- a/nfs4.1/server41tests/st_sequence.py
+++ b/nfs4.1/server41tests/st_sequence.py
@@ -1,6 +1,6 @@
 from st_create_session import create_session
 from xdrdef.nfs4_const import *
-from .environment import check, fail, bad_sessionid, create_file
+from .environment import check, fail, bad_sessionid, create_file, close_file
 from xdrdef.nfs4_type import channel_attrs4
 import nfs_ops
 op = nfs_ops.NFS4ops()
@@ -223,12 +223,15 @@ def testReplayCache007(t, env):
     sess1 = env.c1.new_client_session(env.testname(t))
     res = create_file(sess1, "%s_1" % env.testname(t))
     check(res)
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
     ops = env.home + [op.savefh(),\
           op.rename("%s_1" % env.testname(t), "%s_2" % env.testname(t))]
     res1 = sess1.compound(ops, cache_this=False)
     check(res1, NFS4_OK)
     res2 = sess1.compound(ops, seq_delta=0, cache_this=False)
     check(res2, [NFS4_OK, NFS4ERR_RETRY_UNCACHED_REP])
+    close_file(sess1, fh, stateid=stateid)
 
 def testOpNotInSession(t, env):
     """Operations other than SEQUENCE, BIND_CONN_TO_SESSION, EXCHANGE_ID,
-- 
2.17.2

