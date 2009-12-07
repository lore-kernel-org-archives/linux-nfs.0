From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 28/35] pnfsd: add dlm file layout layout-type
Date: Mon,  7 Dec 2009 11:36:00 +0200
Message-ID: <1260178560-15914-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Export nfsd4_pnfs_dlm_layouttype for use by dlm cluster file systems.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
---
 fs/nfsd/nfs4pnfsdlm.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index db3ae1d..162afaf 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -378,3 +378,9 @@ error:
 	res->lg_seg.length = 0;
 	goto exit;
 }
+
+static int
+nfsd4_pnfs_dlm_layouttype(struct super_block *sb)
+{
+	return LAYOUT_NFSV4_FILES;
+}
-- 
1.6.5.1

