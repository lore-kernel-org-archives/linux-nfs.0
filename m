From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] knfsd: Fix typo in export display, print uid and gid as
	unsigned
Date: Fri, 20 Jul 2007 18:18:15 -0400
Message-ID: <20070720221815.GP6514@fieldses.org>
References: <20070710121949.12548.patches@notabene> <1070710022737.13509@suse.de> <20070713002933.f15724a7.akpm@linux-foundation.org> <20070718230555.GN7111@fieldses.org> <18078.44366.961344.428533@notabene.brown> <20070719153536.GB23093@fieldses.org> <18080.7196.844577.295882@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935627AbXGTWS2@vger.kernel.org>
In-Reply-To: <18080.7196.844577.295882@notabene.brown>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: J. Bruce Fields <bfields@citi.umich.edu>

For display purposes, treat uid's and gid's as unsigned ints for now.
Also fix a typo.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/export.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

On Fri, Jul 20, 2007 at 12:21:16PM +1000, Neil Brown wrote:
> On Thursday July 19, bfields@fieldses.org wrote:
> > Sharp eyes, thanks!  I'll make a patch.  Uh, any objection if I print
> > all those uid's as unsigned while I'm at it?
> 
> I wondered about that too.  I think we have completely removed the
> fiction that 'nobody' is '-2' rather than '65534' so it should be both
> safe and sensible to make them unsigned.

OK!  Here's what I've got.--b.

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 6ab8de4..2d295dd 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1503,9 +1503,9 @@ static void exp_flags(struct seq_file *m, int flag, int fsid,
 	if (flag & NFSEXP_FSID)
 		seq_printf(m, ",fsid=%d", fsid);
 	if (anonu != (uid_t)-2 && anonu != (0x10000-2))
-		seq_printf(m, ",sanonuid=%d", anonu);
+		seq_printf(m, ",anonuid=%u", anonu);
 	if (anong != (gid_t)-2 && anong != (0x10000-2))
-		seq_printf(m, ",sanongid=%d", anong);
+		seq_printf(m, ",anongid=%u", anong);
 	if (fsloc && fsloc->locations_count > 0) {
 		char *loctype = (fsloc->migrated) ? "refer" : "replicas";
 		int i;
-- 
1.5.3.rc2
