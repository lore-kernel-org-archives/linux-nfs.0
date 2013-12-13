Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f44.google.com ([74.125.83.44]:44985 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab3LMKDx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Dec 2013 05:03:53 -0500
Received: by mail-ee0-f44.google.com with SMTP id b57so756499eek.17
        for <linux-nfs@vger.kernel.org>; Fri, 13 Dec 2013 02:03:52 -0800 (PST)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 2/2] nfsd4: ignore nfsv4.1 lockowners in nfsd4_release_lockowner
Date: Fri, 13 Dec 2013 12:03:46 +0200
Message-Id: <1386929026-12627-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52AADAF6.40700@primarydata.com>
References: <52AADAF6.40700@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RELEASE_LOCKOWNER is a NFSv4.0 operation only so it can quickly skip
lockowners created by nfsv4.1 clients.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 84007b6..00424f2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4652,6 +4652,8 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	list_for_each_entry(sop, &nn->ownerstr_hashtbl[hashval], so_strhash) {
 		if (sop->so_is_open_owner)
 			continue;
+		if (sop->so_client->cl_minorversion)
+			continue;
 		if (!same_owner_str(sop, owner, clid))
 			continue;
 		list_for_each_entry(stp, &sop->so_stateids,
-- 
1.8.3.1

