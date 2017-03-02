Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:25855 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753966AbdCBReV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 12:34:21 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 18/18] NFSD remove copy stateid when vfs_copy_file_range completes
Date: Thu, 2 Mar 2017 11:01:42 -0500
Message-ID: <20170302160142.30413-19-kolga@netapp.com>
In-Reply-To: <20170302160142.30413-1-kolga@netapp.com>
References: <20170302160142.30413-1-kolga@netapp.com>
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
index 8a1860e..792cb7a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1462,6 +1462,8 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 		nfsd4_run_cb(&cb_copy->cp_cb);
 	}
 out:
+	list_del(&copy->cps->cp_list);
+	nfs4_free_cp_state(copy->cps);
 	nfs4_put_stid(copy->stid);
 	kfree(copy);
 }
-- 
1.8.3.1

