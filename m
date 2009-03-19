From: Ni Wenjuan <niwj@cn.fujitsu.com>
Subject: [PATCH] Replace NFS4ERR_NOTEMPY with NFS4ERR_EXIST
Date: Thu, 19 Mar 2009 08:37:05 +0800
Message-ID: <49C193B1.8040608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50608 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753422AbZCSAhs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Mar 2009 20:37:48 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a test in rename operation. rename dir1 into existing,nonempty dir2 should
return  NFS4ERR_EXIST instead got NFS4ERR_NOTEMPTY. RFC says if the target is a
directory but not empty, the server will return the error, NFS4ERR_EXIST.

Signed-off-by:Ni Wenjuan  <niwj@cn.fujitsu.com>

---
  fs/nfsd/nfs4proc.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9fa60a3..c1e2e22 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -605,7 +605,7 @@ nfsd4_rename(struct svc_rqst *rqstp, struct
nfsd4_compound_state *cstate,

  	/* the underlying filesystem returns different error's than required
  	 * by NFSv4. both save_fh and current_fh have been verified.. */
-	if (status == nfserr_isdir)
+	if (status == nfserr_isdir || status == nfserr_notempty)
  		status = nfserr_exist;
  	else if ((status == nfserr_notdir) &&
                    (S_ISDIR(cstate->save_fh.fh_dentry->d_inode->i_mode) &&
-- 

