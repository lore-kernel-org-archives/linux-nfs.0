Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:56812 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbaC2Snl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Mar 2014 14:43:41 -0400
Received: by mail-ie0-f169.google.com with SMTP id to1so6265531ieb.14
        for <linux-nfs@vger.kernel.org>; Sat, 29 Mar 2014 11:43:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: Idan Kedar <idank@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfsd: Don't return NFS4ERR_STALE_STATEID for NFSv4.1+
Date: Sat, 29 Mar 2014 14:43:38 -0400
Message-Id: <1396118619-12771-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC5661 obsoletes NFS4ERR_STALE_STATEID in favour of NFS4ERR_BAD_STATEID.

Note that because nfsd encodes the clientid boot time in the stateid, we
can hit this error case in certain scenarios where the Linux client
state management thread exits early, before it has finished recovering
all state.

Reported-by: Idan Kedar <idank@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d5d070fbeb35..dd32f3746e4d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3627,8 +3627,11 @@ static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
 		return nfserr_bad_stateid;
 	status = lookup_clientid(&stateid->si_opaque.so_clid, sessions,
 							nn, &cl);
-	if (status == nfserr_stale_clientid)
+	if (status == nfserr_stale_clientid) {
+		if (sessions)
+			return nfserr_bad_stateid;
 		return nfserr_stale_stateid;
+	}
 	if (status)
 		return status;
 	*s = find_stateid_by_type(cl, stateid, typemask);
-- 
1.9.0

