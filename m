From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 007 of 8] knfsd: nfsd4: vary maximum delegation
	limit based on RAM size
Date: Wed, 27 Jun 2007 22:15:52 -0400
Message-ID: <20070628021551.GB20605@fieldses.org>
References: <20070621142604.727.patches@notabene> <1070621043112.1144@suse.de>
	<20070625205244.bbf0976a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3jY5-0008O7-4k
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 19:15:57 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3jY7-0004Nx-9r
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 19:16:00 -0700
In-Reply-To: <20070625205244.bbf0976a.akpm@linux-foundation.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This code would benefit from a little more explanation.

Also, I screwed up the previous patch and forgot to delete a line, so the
calculation here is off; fix it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 fs/nfsd/nfs4state.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

On Mon, Jun 25, 2007 at 08:52:44PM -0700, Andrew Morton wrote:
>
> Please put yourself in the position of the reader who happens across this
> code and wonders why it is that way.
> 
> They could of course go hunt it out of the git repo but I do think it's
> quite a bit more reader-friendly to explain the thinking in code comments.
>

Yup, sorry about that.  Could you apply this?

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fbbbcab..1b2657f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3203,13 +3203,27 @@ get_nfs4_grace_period(void)
 	return max(user_lease_time, lease_time) * HZ;
 }
 
+/*
+ * Since the lifetime of a delegation isn't limited to that of an open, a
+ * client may quite reasonably hang on to a delegation as long as it has
+ * the inode cached.  This becomes an obvious problem the first time a
+ * client's inode cache approaches the size of the server's total memory.
+ *
+ * For now we avoid this problem by imposing a hard limit on the number
+ * of delegations, which varies according to the server's memory size.
+ */
 static void
 set_max_delegations(void)
 {
 	struct sysinfo sys;
 
 	si_meminfo(&sys);
-	sys.totalram *= sys.mem_unit;
+	/*
+	 * Allow at most 4 delegations per megabyte of RAM.  Quick
+	 * estimates suggest that in the worst case (where every delegation
+	 * is for a different inode), a delegation could take about 1.5K,
+	 * giving a worst case usage of about 6% of memory.
+	 */
 	sys.totalram >>= (18 - PAGE_SHIFT);
 	max_delegations = (unsigned int) sys.totalram;
 }
-- 
1.5.2.58.g98ee


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
