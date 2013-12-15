Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f44.google.com ([74.125.83.44]:57351 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388Ab3LOPwF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Dec 2013 10:52:05 -0500
Received: by mail-ee0-f44.google.com with SMTP id b57so1753808eek.3
        for <linux-nfs@vger.kernel.org>; Sun, 15 Dec 2013 07:52:03 -0800 (PST)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH v2 2/2] nfsd4: ignore nfsv4.1 lockowners in nfsd4_release_lockowner
Date: Sun, 15 Dec 2013 17:51:59 +0200
Message-Id: <1387122719-23656-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52ADCFC2.7060504@gmail.com>
References: <52ADCFC2.7060504@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RELEASE_LOCKOWNER is a NFSv4.0 operation only so it can quickly skip
lockowners created by nfsv4.1 clients.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b04f765..7d79494 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4652,6 +4652,9 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	list_for_each_entry(sop, &nn->ownerstr_hashtbl[hashval], so_strhash) {
 		if (sop->so_is_open_owner)
 			continue;
+		/* This is NFSv4.0 only operation, skip NFSv4.x lockowners */
+		if (sop->so_client->cl_minorversion)
+			continue;
 		if (!same_owner_str(sop, owner, clid))
 			continue;
 		lo = lockowner(sop);
-- 
1.8.3.1

