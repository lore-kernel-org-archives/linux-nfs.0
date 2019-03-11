Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C524C4360F
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:49:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2DB6820657
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:49:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727508AbfCKPtw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Mar 2019 11:49:52 -0400
Received: from mx1.redhat.com ([209.132.183.28]:49646 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727531AbfCKPtw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Mar 2019 11:49:52 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E52D230820E4;
        Mon, 11 Mar 2019 15:49:51 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-19.rdu2.redhat.com [10.10.122.19])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C8F435C229;
        Mon, 11 Mar 2019 15:49:51 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 37A19214F6; Mon, 11 Mar 2019 11:49:51 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Subject: [pynfs PATCH 1/3] nfs4.1: don't cache sessionids and clientids after destroying
Date:   Mon, 11 Mar 2019 11:49:49 -0400
Message-Id: <20190311154951.6144-2-smayhew@redhat.com>
In-Reply-To: <20190311154951.6144-1-smayhew@redhat.com>
References: <20190311154951.6144-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 11 Mar 2019 15:49:51 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Test.run() cleans up session and client records after every test, but
that cleanup doesn't get rid of the locally cached sessionids and
clientids, resulting in subsequent tests sending a multiple bogus
DESTROY_SESSIONs and DESTROY_CLIENTIDs which all return
NFS4ERR_BADSESSION and NFS4ERR_STALE_CLIENTID.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs4.1/server41tests/environment.py | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 9e1201f..1a898f8 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -256,11 +256,13 @@ class Environment(testmod.Environment):
         """Destroy client name env.c1"""
         for sessionid in self.c1.sessions.keys():
             self.c1.compound([op.destroy_session(sessionid)])
+            del(self.c1.sessions[sessionid])
 
     def clean_clients(self):
         """Destroy client name env.c1"""
         for clientid in self.c1.clients.keys():
             self.c1.compound([op.destroy_clientid(clientid)])
+            del(self.c1.clients[clientid])
 
 #########################################
 debug_fail = False
-- 
2.17.2

