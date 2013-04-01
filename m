Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:6770 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759676Ab3DAUBk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Apr 2013 16:01:40 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4: Handle NFS4ERR_DELAY and NFS4ERR_GRACE in nfs4_open_delegation_recall
Date: Mon,  1 Apr 2013 16:01:30 -0400
Message-Id: <1364846493-11145-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1364846493-11145-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1364846493-11145-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A server shouldn't normally return NFS4ERR_GRACE if the client holds a
delegation, since no conflicting lock reclaims can be granted, however
the spec does not require the server to grant the open in this
instance

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/nfs4proc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e7c0e64..a549ffe 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1432,6 +1432,12 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
 			case -ENOMEM:
 				err = 0;
 				goto out;
+			case -NFS4ERR_DELAY:
+			case -NFS4ERR_GRACE:
+				set_bit(NFS_DELEGATED_STATE, &state->flags);
+				ssleep(1);
+				err = -EAGAIN;
+				goto out;
 		}
 		set_bit(NFS_DELEGATED_STATE, &state->flags);
 		err = nfs4_handle_exception(server, err, &exception);
-- 
1.8.1.4

