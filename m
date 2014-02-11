Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41160 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754289AbaBKTiG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Feb 2014 14:38:06 -0500
Date: Tue, 11 Feb 2014 14:38:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] nfsd4: fix acl buffer overrun
Message-ID: <20140211193801.GA22695@fieldses.org>
References: <20140208204522.GG8801@fieldses.org>
 <20140209020933.GA23163@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140209020933.GA23163@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

4ac7249ea5a0ceef9f8269f63f33cc873c3fac61 "nfsd: use get_acl and
->set_acl" forgets to set the size in the case get_acl() succeeds, so
_posix_to_nfsv4_one() can then write past the end of its allocation.
Symptoms were slab corruption warnings.

Also, some minor cleanup while we're here.  (Among other things, note
that the first few lines guarantee that pacl is non-NULL.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4acl.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

On Sat, Feb 08, 2014 at 09:09:33PM -0500, J. Bruce Fields wrote:
> On Sat, Feb 08, 2014 at 03:45:22PM -0500, bfields wrote:
> > I'm getting warnings about corruption of the kmalloc-32 slab on an nfs
> > server while running some regression tests.
> > 
> > A bisect lands on 9fe55eea7e4b444bafc42fa0000cc2d1d2847275 "Fix race
> > when checking i_size on direct i/o read".  Is there any known problem
> > here?
> > 
> > It doesn't reproduce immediately and it's possible I could have made a
> > mistake on the bisect.
> 
> Argh, apologies, yes--I'm able to reproduce the corruption before that
> commit.  I'll keep looking....

Fortunately my mistake was at the end of the bisect so the offending
commit was nearby (and clearly labeled "nfsd:...").  This fixes the
regression I was seeing.  I intend to include it in a pull request for
3.14 soon.

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index d3a5871..d190e33 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -151,17 +151,15 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry,
 		pacl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
 		if (IS_ERR(pacl))
 			return PTR_ERR(pacl);
-		/* allocate for worst case: one (deny, allow) pair each: */
-		size += 2 * pacl->a_count;
 	}
+	/* allocate for worst case: one (deny, allow) pair each: */
+	size += 2 * pacl->a_count;
 
 	if (S_ISDIR(inode->i_mode)) {
 		flags = NFS4_ACL_DIR;
 		dpacl = get_acl(inode, ACL_TYPE_DEFAULT);
 		if (dpacl)
 			size += 2 * dpacl->a_count;
-	} else {
-		dpacl = NULL;
 	}
 
 	*acl = nfs4_acl_new(size);
@@ -170,8 +168,7 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry,
 		goto out;
 	}
 
-	if (pacl)
-		_posix_to_nfsv4_one(pacl, *acl, flags & ~NFS4_ACL_TYPE_DEFAULT);
+	_posix_to_nfsv4_one(pacl, *acl, flags & ~NFS4_ACL_TYPE_DEFAULT);
 
 	if (dpacl)
 		_posix_to_nfsv4_one(dpacl, *acl, flags | NFS4_ACL_TYPE_DEFAULT);
-- 
1.7.9.5

