From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 007 of 8] knfsd: nfsd4: vary maximum delegation
 limit based on RAM size
Date: Wed, 27 Jun 2007 19:36:13 -0700
Message-ID: <20070627193613.746dfbf3.akpm@linux-foundation.org>
References: <20070621142604.727.patches@notabene> <1070621043112.1144@suse.de>
	<20070625205244.bbf0976a.akpm@linux-foundation.org>
	<20070628021551.GB20605@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3jrz-0001xz-Ns
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 19:36:31 -0700
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3js3-00022O-10
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 19:36:35 -0700
In-Reply-To: <20070628021551.GB20605@fieldses.org>
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

On Wed, 27 Jun 2007 22:15:52 -0400 "J. Bruce Fields" <bfields@fieldses.org> wrote:

> +	/*
> +	 * Allow at most 4 delegations per megabyte of RAM.  Quick
> +	 * estimates suggest that in the worst case (where every delegation
> +	 * is for a different inode), a delegation could take about 1.5K,
> +	 * giving a worst case usage of about 6% of memory.
> +	 */
>  	sys.totalram >>= (18 - PAGE_SHIFT);

6% of 32GB is 2GB is too much for a large highmem machine.  We should base
this on the amount of kernel-addressable memory (aka lowmem).

How's this?

static void
set_max_delegations(void)
{
	/*
	 * Allow at most 4 delegations per megabyte of RAM.  Quick
	 * estimates suggest that in the worst case (where every delegation
	 * is for a different inode), a delegation could take about 1.5K,
	 * giving a worst case usage of about 6% of memory.
	 */
	max_delegations = nr_free_buffer_pages() >> (20 - 2 - PAGE_SHIFT);
}


 fs/nfsd/nfs4state.c |    7 ++-----
 mm/page_alloc.c     |    1 +

diff -puN fs/nfsd/nfs4state.c~knfsd-nfsd4-vary-maximum-delegation-limit-based-on-ram-size-fix-fix-fix-fix fs/nfsd/nfs4state.c
--- a/fs/nfsd/nfs4state.c~knfsd-nfsd4-vary-maximum-delegation-limit-based-on-ram-size-fix-fix-fix-fix
+++ a/fs/nfsd/nfs4state.c
@@ -49,6 +49,7 @@
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
 #include <linux/namei.h>
+#include <linux/swap.h>
 #include <linux/mutex.h>
 #include <linux/lockd/bind.h>
 #include <linux/module.h>
@@ -3210,17 +3211,13 @@ get_nfs4_grace_period(void)
 static void
 set_max_delegations(void)
 {
-	struct sysinfo sys;
-
-	si_meminfo(&sys);
 	/*
 	 * Allow at most 4 delegations per megabyte of RAM.  Quick
 	 * estimates suggest that in the worst case (where every delegation
 	 * is for a different inode), a delegation could take about 1.5K,
 	 * giving a worst case usage of about 6% of memory.
 	 */
-	sys.totalram >>= (18 - PAGE_SHIFT);
-	max_delegations = (unsigned int) sys.totalram;
+	max_delegations = nr_free_buffer_pages() >> (20 - 2 - PAGE_SHIFT);
 }
 
 /* initialization to perform when the nfsd service is started: */
diff -puN mm/page_alloc.c~knfsd-nfsd4-vary-maximum-delegation-limit-based-on-ram-size-fix-fix-fix-fix mm/page_alloc.c
--- a/mm/page_alloc.c~knfsd-nfsd4-vary-maximum-delegation-limit-based-on-ram-size-fix-fix-fix-fix
+++ a/mm/page_alloc.c
@@ -1729,6 +1729,7 @@ unsigned int nr_free_buffer_pages(void)
 {
 	return nr_free_zone_pages(gfp_zone(GFP_USER));
 }
+EXPORT_SYMBOL_GPL(nr_free_buffer_pages);
 
 /*
  * Amount of free RAM allocatable within all zones
_


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
