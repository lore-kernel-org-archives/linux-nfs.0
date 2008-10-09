From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: connectathon test failures
Date: Thu, 09 Oct 2008 13:36:13 -0400
Message-ID: <1223573773.7494.21.camel@localhost>
References: <20081008225543.GG14527@fieldses.org>
	 <20081009020300.GA17896@fieldses.org> <20081009021011.GB17896@fieldses.org>
	 <1223562985.7494.17.camel@localhost>  <20081009155347.GB28785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23024 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754026AbYJIRgv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 13:36:51 -0400
In-Reply-To: <20081009155347.GB28785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-10-09 at 11:53 -0400, J. Bruce Fields wrote:
> On Thu, Oct 09, 2008 at 10:36:25AM -0400, Trond Myklebust wrote:
> > On Wed, 2008-10-08 at 22:10 -0400, J. Bruce Fields wrote:
> > > On Wed, Oct 08, 2008 at 10:03:00PM -0400, bfields wrote:
> > > > On Wed, Oct 08, 2008 at 06:55:43PM -0400, bfields wrote:
> > > > > I'm getting connectathon test failures with the latest merge of code
> > > > > from both our trees, linux-to-linux over v3 and v4.
> > > > > 
> > > > > I just got this a moment ago, so haven't tried to track it down at all
> > > > > yet--but I seem to recall in the past this sort of failure has been an
> > > > > attribute revalidation problem (usually with the ext3 ctime resolution
> > > > > at least partly to blame).
> > > > 
> > > > The failure first happens with d65f557f3 "NFS: Fix
> > > > nfs_post_op_update_inode_force_wcc()".
> > > 
> > > Err, sorry, no: that was the last *good* one!  It's the following one (
> > > (4dc05efb86 "NFS: Convert __nfs_revalidate_inode() to use
> > > nfs_refresh_inode()") where the failures start.
> > 
> > Hmm... That patch should be correct. I rather suspect a problem with the
> > updating of nfsi->last_updated.
> > 
> > Could you see if something like the following patch helps?
> 
> Yep, if I apply this on top of your linux-mm
> (19d771f3caccaf66ce2fb539319222139e5b4e88) then I can no longer see the
> failure.
> 
> --b.

OK. Having thought a little bit more about this, I think we can just
delete the wraparound protection in nfs_update_inode(). We already have
similar protection in nfs_inode_attrs_need_update()...

Cheers
  Trond
--------------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 9 Oct 2008 13:27:55 -0400
NFS: Fix attribute updates

This fixes a regression seen when running the Connectathon testsuite
against an ext3 filesystem. The reason was that the inode was constantly
being marked as 'just updated' by the jiffy wraparound test.
This again meant that newer GETATTR calls were failing to pass the
nfs_inode_attrs_need_update() test unless the changes caused a ctime update
on the server, since they were perceived as having been started before the
latest inode update.

Given that nfs_inode_attrs_need_update() already checks for wraparound
of nfsi->last_updated, we can drop the buggy "protection" in
nfs_update_inode().

Also make a slight micro-optimisation of nfs_inode_attrs_need_update(): we
are more often going to see time_after(fattr->time_start, nfsi->last_updated)
be true, rather than seeing an update of ctime/size, so put that test
first to ensure that we optimise away the ctime/size tests.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e25009f..6554281 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -933,10 +933,10 @@ static int nfs_inode_attrs_need_update(const struct inode *inode, const struct n
 {
 	const struct nfs_inode *nfsi = NFS_I(inode);
 
-	return nfs_ctime_need_update(inode, fattr) ||
-			nfs_size_need_update(inode, fattr) ||
-			time_after(fattr->time_start, nfsi->last_updated) ||
-			time_after(nfsi->last_updated, jiffies);
+	return time_after(fattr->time_start, nfsi->last_updated) ||
+		nfs_ctime_need_update(inode, fattr) ||
+		nfs_size_need_update(inode, fattr) ||
+		time_after(nfsi->last_updated, jiffies);
 }
 
 static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
@@ -1167,11 +1167,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				nfsi->attrtimeo = NFS_MAXATTRTIMEO(inode);
 			nfsi->attrtimeo_timestamp = now;
 		}
-		/*
-		 * Avoid jiffy wraparound issues with nfsi->last_updated
-		 */
-		if (!time_in_range(nfsi->last_updated, nfsi->read_cache_jiffies, now))
-			nfsi->last_updated = nfsi->read_cache_jiffies;
 	}
 	invalid &= ~NFS_INO_INVALID_ATTR;
 	/* Don't invalidate the data if we were to blame */


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
