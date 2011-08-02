Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35141 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754811Ab1HBSvF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2011 14:51:05 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andy Adamson <andros@netapp.com>
Cc: Peng Tao <bergwolf@gmail.com>, Jim Rees <rees@umich.edu>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v2 2/2] NFSv4.1: Return NFS4ERR_BADSESSION to callbacks during session resets
Date: Tue,  2 Aug 2011 14:50:40 -0400
Message-Id: <1312311040-9400-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1312311040-9400-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1312306214.2823.10.camel@lade.trondhjem.org>
 <1312311040-9400-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If the client is in the process of resetting the session when it receives
a callback, then returning NFS4ERR_DELAY may cause a deadlock with the
DESTROY_SESSION call.

Basically, if the client returns NFS4ERR_DELAY in response to the
CB_SEQUENCE call, then the server is entitled to believe that the
client is busy because it is already processing that call. In that
case, the server is perfectly entitled to respond with a
NFS4ERR_BACK_CHAN_BUSY to any DESTROY_SESSION call.

Fix this by having the client reply with a NFS4ERR_BADSESSION in
response to the callback if it is resetting the session.

Cc: stable@kernel.org [2.6.38+]
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 0ab8202..43926ad 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -452,6 +452,11 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	if (test_bit(NFS4_SESSION_DRAINING, &clp->cl_session->session_state)) {
 		spin_unlock(&tbl->slot_tbl_lock);
 		status = htonl(NFS4ERR_DELAY);
+		/* Return NFS4ERR_BADSESSION if we're draining the session
+		 * in order to reset it.
+		 */
+		if (test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state))
+			status = htonl(NFS4ERR_BADSESSION);
 		goto out;
 	}
 
-- 
1.7.6

