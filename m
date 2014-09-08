Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:44811 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121AbaIHOrK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 10:47:10 -0400
Received: by mail-qa0-f45.google.com with SMTP id v10so2362213qac.18
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 07:47:09 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: [PATCH v3 8/8] nfsd: reject reclaim request when client has already sent RECLAIM_COMPLETE
Date: Mon,  8 Sep 2014 10:46:49 -0400
Message-Id: <1410187609-10319-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410187609-10319-1-git-send-email-jlayton@primarydata.com>
References: <1410187609-10319-1-git-send-email-jlayton@primarydata.com>
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
index 951c882b1581..c4c8d0621dde 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5660,6 +5660,9 @@ nfs4_check_open_reclaim(clientid_t *clid,
 	if (status)
 		return nfserr_reclaim_bad;
 
+	if (test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE, &cstate->clp->cl_flags))
+		return nfserr_no_grace;
+
 	if (nfsd4_client_record_check(cstate->clp))
 		return nfserr_reclaim_bad;
 
-- 
1.9.3

