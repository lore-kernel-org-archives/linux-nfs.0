Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:40716 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756593AbaIWVgG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 17:36:06 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn15so5411366igb.9
        for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 14:36:06 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 23 Sep 2014 14:36:05 -0700
Message-ID: <CAN-5tyGn0mLHrk+C+a9CU22YD3MXJm5j3k=2ZrGz5XnyhT-+Uw@mail.gmail.com>
Subject: [PATCH 1/1] Fixing lease renewal
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit c9fdeb28 removed a 'continue' after checking if the lease needs
to be renewed. However, if client hasn't moved, the code falls down to
starting reboot recovery erroneously (ie., sends open reclaim and gets
back stale_clientid error) before recovering from getting stale_clientid
on the renew operation.

---
 fs/nfs/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 22fe351..790aed3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2345,6 +2345,8 @@ static void nfs4_state_manager(struct nfs_client *clp)
                        status = nfs4_check_lease(clp);
                        if (status < 0)
                                goto out_error;
+                       if (!test_bit(NFS4CLNT_MOVED, &clp->cl_state))
+                               continue;
                }

                if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
--
1.7.1
