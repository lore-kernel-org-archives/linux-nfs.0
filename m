Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:56781 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753658AbaIONOY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 09:14:24 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so4041628qcy.1
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 06:14:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v4 3/9] nfsd: reject reclaim request when client has already sent RECLAIM_COMPLETE
Date: Mon, 15 Sep 2014 09:14:04 -0400
Message-Id: <1410786850-18194-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410786850-18194-1-git-send-email-jlayton@primarydata.com>
References: <1410786850-18194-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As stated in RFC 5661, section 18.51.3:

    Once a RECLAIM_COMPLETE is done, there can be no further reclaim
    operations for locks whose scope is defined as having completed
    recovery.  Once the client sends RECLAIM_COMPLETE, the server will
    not allow the client to do subsequent reclaims of locking state for
    that scope and, if these are attempted, will return
    NFS4ERR_NO_GRACE.

Ensure that we enforce that requirement.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 119d5eeca2cf..d4de5b61e1e7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5664,6 +5664,9 @@ nfs4_check_open_reclaim(clientid_t *clid,
 	if (status)
 		return nfserr_reclaim_bad;
 
+	if (test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE, &cstate->clp->cl_flags))
+		return nfserr_no_grace;
+
 	if (nfsd4_client_record_check(cstate->clp))
 		return nfserr_reclaim_bad;
 
-- 
1.9.3

