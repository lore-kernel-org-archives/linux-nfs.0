Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 8 Feb 2010 20:01:18 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Subject: 2.6.33 fix
Message-ID: <20100209010118.GB17879@fieldses.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
        linux-kernel@vger.kernel.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following 2.6.33 regression fix from the for-2.6.33
branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.33

--b.

commit 260c64d23532caf19abb77e696971da05c388489
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Mon Feb 8 13:42:26 2010 -0500

    Revert "nfsd4: fix error return when pseudoroot missing"
    
    Commit f39bde24b275ddc45d fixed the error return from PUTROOTFH in the
    case where there is no pseudofilesystem.
    
    This is really a case we shouldn't hit on a correctly configured server:
    in the absence of a root filehandle, there's no point accepting version
    4 NFS rpc calls at all.
    
    But the shared responsibility between kernel and userspace here means
    the kernel on its own can't eliminate the possiblity of this happening.
    And we have indeed gotten this wrong in distro's, so new client-side
    mount code that attempts to negotiate v4 by default first has to work
    around this case.
    
    Therefore when commit f39bde24b275ddc45d arrived at roughly the same
    time as the new v4-default mount code, which explicitly checked only for
    the previous error, the result was previously fine mounts suddenly
    failing.
    
    We'll fix both sides for now: revert the error change, and make the
    client-side mount workaround more robust.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c487810..a0c4016 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1316,19 +1316,11 @@ rqst_exp_parent(struct svc_rqst *rqstp, struct path *path)
 
 static struct svc_export *find_fsidzero_export(struct svc_rqst *rqstp)
 {
-	struct svc_export *exp;
 	u32 fsidv[2];
 
 	mk_fsid(FSID_NUM, fsidv, 0, 0, 0, NULL);
 
-	exp = rqst_exp_find(rqstp, FSID_NUM, fsidv);
-	/*
-	 * We shouldn't have accepting an nfsv4 request at all if we
-	 * don't have a pseudoexport!:
-	 */
-	if (IS_ERR(exp) && PTR_ERR(exp) == -ENOENT)
-		exp = ERR_PTR(-ESERVERFAULT);
-	return exp;
+	return rqst_exp_find(rqstp, FSID_NUM, fsidv);
 }
 
 /*
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
