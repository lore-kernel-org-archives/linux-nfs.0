Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:39085 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965236AbeALWmf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jan 2018 17:42:35 -0500
Received: by mail-io0-f193.google.com with SMTP id b198so4788929iof.6
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jan 2018 14:42:35 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: Detect unhashed stids in nfsd4_verify_open_stid()
Date: Fri, 12 Jan 2018 17:42:30 -0500
Message-Id: <20180112224230.129322-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The state of the stid is guaranteed by 2 locks:
- The nfs4_client 'cl_lock' spinlock
- The nfs4_ol_stateid 'st_mutex' mutex

so it is quite possible for the stid to be unhashed after lookup,
but before calling nfsd4_lock_ol_stateid(). So we do need to check
for a zero value for 'sc_type' in nfsd4_verify_open_stid().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8d53d29161f5..b5bda115f6a9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3591,6 +3591,7 @@ nfsd4_verify_open_stid(struct nfs4_stid *s)
 	switch (s->sc_type) {
 	default:
 		break;
+	case 0:
 	case NFS4_CLOSED_STID:
 	case NFS4_CLOSED_DELEG_STID:
 		ret = nfserr_bad_stateid;
-- 
2.14.3

