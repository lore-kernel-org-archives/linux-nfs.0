Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nautica.notk.org ([91.121.71.147]:33418 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330AbbFDPOh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 11:14:37 -0400
From: Dominique Martinet <dominique.martinet@cea.fr>
To: linux-nfs@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-kernel@vger.kernel.org,
        Dominique Martinet <dominique.martinet@cea.fr>,
        "Frank S. Filz" <ffilzlnx@mindspring.com>
Subject: [PATCH] NFSv4: handle nfs4_get_referral failure
Date: Thu,  4 Jun 2015 17:04:17 +0200
Message-Id: <1433430257-11894-1-git-send-email-dominique.martinet@cea.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_proc_lookup_common is supposed to return a posix error, we have to
handle any error returned that isn't errno

Reported-by: Olga Kornievskaia <kolga@netapp.com>
Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
Signed-off-by: Dominique Martinet <dominique.martinet@cea.fr>
---

Other way of fixing it would be to return something like -EIO directly
in nfs4_get_referral, but I believe handling exception is the right
thing to do.
Only other return code atm is -ENOMEM which probably isn't recoverable?

 fs/nfs/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 627f37c..e7fbf24 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3356,6 +3356,8 @@ static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
 			goto out;
 		case -NFS4ERR_MOVED:
 			err = nfs4_get_referral(client, dir, name, fattr, fhandle);
+			if (err == -NFS4ERR_MOVED)
+				err = nfs4_handle_exception(NFS_SERVER(dir), err, &exception);
 			goto out;
 		case -NFS4ERR_WRONGSEC:
 			err = -EPERM;
-- 
2.4.2

