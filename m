Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35184 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbbJTQBK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 12:01:10 -0400
Received: by qkbl190 with SMTP id l190so9546284qkb.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 09:01:10 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] create_session: ensure that we send an auth flavor in CREATE_SESSION call
Date: Tue, 20 Oct 2015 12:01:01 -0400
Message-Id: <1445356861-13860-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1445356861-13860-1-git-send-email-jeff.layton@primarydata.com>
References: <1445356861-13860-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...it is required.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 nfs4.1/server41tests/st_create_session.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index 4c56bb45cc8e..d3b7635545ba 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -13,7 +13,7 @@ def create_session(c, clientid, sequenceid, cred=None, flags=0):
     chan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[])
     res = c.compound([op.create_session(clientid, sequenceid, flags,
                                         chan_attrs, chan_attrs,
-                                        123, [])], cred)
+                                        123, [callback_sec_parms4(0)])], cred)
     return res
 
 ###############################################
@@ -305,7 +305,7 @@ def testRdmaArray2(t, env):
     chan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[13, 57])
     ops = [op.create_session(c.clientid, c.seqid, 0,
                              chan_attrs, chan_attrs,
-                             c.c.prog, [])]
+                             c.c.prog, [callback_sec_parms4(0)])]
     c = c.c
     xid = c.compound_async(ops, checks=False)
     try:
-- 
2.4.3

