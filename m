Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:35369 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbaIXNLG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 09:11:06 -0400
Received: by mail-ie0-f182.google.com with SMTP id tp5so6171354ieb.27
        for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 06:11:04 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 24 Sep 2014 09:11:04 -0400
Message-ID: <CAN-5tyFQihuK22n_bzsO0LtqQBM+KW6vELt7H_DPEF0RFdoDQQ@mail.gmail.com>
Subject: [PATCH 1/1] Fixing lease renewal
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit c9fdeb28 removed a 'continue' after checking if the lease needs
to be renewed. However, if client hasn't moved, the code falls down to
starting reboot recovery erroneously (ie., sends open reclaim and gets
back stale_clientid error) before recovering from getting stale_clientid
on the renew operation.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4state.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 22fe351..4616598 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2340,11 +2340,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
                        continue;
                }

-               if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
+               if (!test_bit(NFS4CLNT_MOVED, &clp->cl_state) &&
+                    test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
                        section = "check lease";
                        status = nfs4_check_lease(clp);
                        if (status < 0)
                                goto out_error;
+                       continue;
                }

                if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
-- 
1.7.1
