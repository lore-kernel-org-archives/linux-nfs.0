Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:44962 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611AbcEKWOQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2016 18:14:16 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id B85962802A8
	for <linux-nfs@vger.kernel.org>; Thu, 12 May 2016 00:14:13 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id AC75A1586
	for <linux-nfs@vger.kernel.org>; Thu, 12 May 2016 00:14:13 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs4: client: do not send empty SETATTR after OPEN_CREATE
Date: Thu, 12 May 2016 00:14:03 +0200
Message-Id: <1463004843-3733-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OPEN_CREATE with EXCLUSIVE4_1 sends initial file permission.
Ignoring  fact, that server have indicated that file mod is set, client
will send yet another SETATTR request, but, as mode is already set,
new SETATTR will be empty. This is not a problem, nevertheless
an extra roundtrip and slow open on high latency networks.

This change is aims to by-pass setattr if there are no attributes defined.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/nfs4proc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 327b8c3..f6b278f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2724,6 +2724,12 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 		.inode = inode,
 	};
 	int err;
+	/*
+	 * a shortcut: it there are no attributes to be updated, do not send setattr at all
+	 */
+	if (sattr->ia_valid == ATTR_OPEN)
+		return 0;
+
 	do {
 		err = _nfs4_do_setattr(inode, cred, fattr, sattr, state, ilabel, olabel);
 		switch (err) {
-- 
2.5.5

