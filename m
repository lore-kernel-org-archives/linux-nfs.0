Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:31185 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934064AbdGKQpC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:45:02 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 41/42] NFSD remove copy stateid when vfs_copy_file_range completes
Date: Tue, 11 Jul 2017 12:44:15 -0400
Message-ID: <20170711164416.1982-42-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Before this patch, the copy state information sticks around until
destination file is closed. However, we can release the resources
earlier when copy is done.

In this patch, I choose to remove the stateid after vfs copy is
done but before CB_OFFLOAD is done. The reason is simple because
I don't need to keep track of the nfsd_net structure then when
doing the callback (alternatively, we also need to copy the
nfsd_net structure for the callback). The drawback is that time
copy state information is available for query by OFFLOAD_STATUS
is slightly less.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1094286..86c20fa 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1459,6 +1459,8 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 			&nfsd4_cb_offload_ops, NFSPROC4_CLNT_CB_OFFLOAD);
 	nfsd4_run_cb(&cb_copy->cp_cb);
 out:
+	list_del(&copy->cps->cp_list);
+	nfs4_free_cp_state(copy->cps);
 	nfs4_put_stid(copy->stid);
 	kfree(copy);
 	return;
-- 
1.8.3.1

