From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] knfsd: cleanup nfsd4 properly on module init failure
Date: Thu, 15 Nov 2007 16:56:56 -0500
Message-ID: <1195163823-24609-2-git-send-email-bfields@citi.umich.edu>
References: <1195163823-24609-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <1195163823-24609-1-git-send-email-bfields@citi.umich.edu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

We forgot to shut down the nfs4 state and idmapping code in this case.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsctl.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 77dc989..d8d50a7 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -695,12 +695,14 @@ static int __init init_nfsd(void)
 	}
 	retval = register_filesystem(&nfsd_fs_type);
 	if (retval) {
+		nfsd_idmap_shutdown();
 		nfsd_export_shutdown();
 		nfsd_cache_shutdown();
 		remove_proc_entry("fs/nfs/exports", NULL);
 		remove_proc_entry("fs/nfs", NULL);
 		nfsd_stat_shutdown();
 		nfsd_lockd_shutdown();
+		nfsd4_free_slabs();
 	}
 	return retval;
 }
-- 
1.5.3.5.561.g140d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
