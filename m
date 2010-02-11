Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59688 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756578Ab0BKRpD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Feb 2010 12:45:03 -0500
Subject: [GIT PULL] Please pull NFS client bugfixes for mainline
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 11 Feb 2010 12:44:44 -0500
Message-ID: <1265910284.478.5.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/fscache.c    |    9 ++++-----
 fs/nfs/mount_clnt.c |    2 +-
 fs/nfs/nfs2xdr.c    |    2 +-
 fs/nfs/nfs4xdr.c    |    6 +++---
 fs/nfs/write.c      |    3 +--
 5 files changed, 10 insertions(+), 12 deletions(-)

commit fdcb45777a3d1689c5541e1f85ee3ebbd197d2c1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Feb 8 09:32:40 2010 -0500

    NFS: Fix the mapping of the NFSERR_SERVERFAULT error
    
    It was recently pointed out that the NFSERR_SERVERFAULT error, which is
    designed to inform the user of a serious internal error on the server, was
    being mapped to an error value that is internal to the kernel.
    
    This patch maps it to the error EREMOTEIO, which is exported to userland
    through errno.h.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 7549ad5f9b6eda49bbac4b14c5b8f37bf464f922
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Feb 8 09:32:34 2010 -0500

    NFS: Remove a redundant check for PageFsCache in nfs_migrate_page()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Acked-by: David Howells <dhowells@redhat.com>

commit 2c1740098c708b465e87637b237feb2fd98f129a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Feb 8 09:32:27 2010 -0500

    NFS: Fix a bug in nfs_fscache_release_page()
    
    Not having an fscache cookie is perfectly valid if the user didn't mount
    with the fscache option.
    
    This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=15234
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Acked-by: David Howells <dhowells@redhat.com>
    Cc: stable@kernel.org

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index fa58800..237874f 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -354,12 +354,11 @@ void nfs_fscache_reset_inode_cookie(struct inode *inode)
  */
 int nfs_fscache_release_page(struct page *page, gfp_t gfp)
 {
-	struct nfs_inode *nfsi = NFS_I(page->mapping->host);
-	struct fscache_cookie *cookie = nfsi->fscache;
-
-	BUG_ON(!cookie);
-
 	if (PageFsCache(page)) {
+		struct nfs_inode *nfsi = NFS_I(page->mapping->host);
+		struct fscache_cookie *cookie = nfsi->fscache;
+
+		BUG_ON(!cookie);
 		dfprintk(FSCACHE, "NFS: fscache releasepage (0x%p/0x%p/0x%p)\n",
 			 cookie, page, nfsi);
 
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 0adefc4..59047f8 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -120,7 +120,7 @@ static struct {
 	{ .status = MNT3ERR_INVAL,		.errno = -EINVAL,	},
 	{ .status = MNT3ERR_NAMETOOLONG,	.errno = -ENAMETOOLONG,	},
 	{ .status = MNT3ERR_NOTSUPP,		.errno = -ENOTSUPP,	},
-	{ .status = MNT3ERR_SERVERFAULT,	.errno = -ESERVERFAULT,	},
+	{ .status = MNT3ERR_SERVERFAULT,	.errno = -EREMOTEIO,	},
 };
 
 struct mountres {
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 5e078b2..7bc2da8 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -699,7 +699,7 @@ static struct {
 	{ NFSERR_BAD_COOKIE,	-EBADCOOKIE	},
 	{ NFSERR_NOTSUPP,	-ENOTSUPP	},
 	{ NFSERR_TOOSMALL,	-ETOOSMALL	},
-	{ NFSERR_SERVERFAULT,	-ESERVERFAULT	},
+	{ NFSERR_SERVERFAULT,	-EREMOTEIO	},
 	{ NFSERR_BADTYPE,	-EBADTYPE	},
 	{ NFSERR_JUKEBOX,	-EJUKEBOX	},
 	{ -1,			-EIO		}
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e437fd6..5cd5184 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4631,7 +4631,7 @@ static int decode_sequence(struct xdr_stream *xdr,
 	 * If the server returns different values for sessionID, slotID or
 	 * sequence number, the server is looney tunes.
 	 */
-	status = -ESERVERFAULT;
+	status = -EREMOTEIO;
 
 	if (memcmp(id.data, res->sr_session->sess_id.data,
 		   NFS4_MAX_SESSIONID_LEN)) {
@@ -5774,7 +5774,7 @@ static struct {
 	{ NFS4ERR_BAD_COOKIE,	-EBADCOOKIE	},
 	{ NFS4ERR_NOTSUPP,	-ENOTSUPP	},
 	{ NFS4ERR_TOOSMALL,	-ETOOSMALL	},
-	{ NFS4ERR_SERVERFAULT,	-ESERVERFAULT	},
+	{ NFS4ERR_SERVERFAULT,	-EREMOTEIO	},
 	{ NFS4ERR_BADTYPE,	-EBADTYPE	},
 	{ NFS4ERR_LOCKED,	-EAGAIN		},
 	{ NFS4ERR_SYMLINK,	-ELOOP		},
@@ -5801,7 +5801,7 @@ nfs4_stat_to_errno(int stat)
 	}
 	if (stat <= 10000 || stat > 10100) {
 		/* The server is looney tunes. */
-		return -ESERVERFAULT;
+		return -EREMOTEIO;
 	}
 	/* If we cannot translate the error, the recovery routines should
 	 * handle it.
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7b54b8b..d63d964 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1598,8 +1598,7 @@ int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 	struct nfs_page *req;
 	int ret;
 
-	if (PageFsCache(page))
-		nfs_fscache_release_page(page, GFP_KERNEL);
+	nfs_fscache_release_page(page, GFP_KERNEL);
 
 	req = nfs_find_and_lock_request(page);
 	ret = PTR_ERR(req);

