Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53157 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161705Ab2GLWkJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jul 2012 18:40:09 -0400
Date: Thu, 12 Jul 2012 18:40:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: DCACHE_DISCONNECTED use in try_to_ascend/d_kill
Message-ID: <20120712224008.GF24162@fieldses.org>
References: <20120712222849.GE24162@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120712222849.GE24162@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 12, 2012 at 06:28:49PM -0400, bfields wrote:
> I've been trying to figure out if we can pare down DCACHE_DISCONNECTED
> uses to only those required by exportfs, and ran across this one.

There's also one DCACHE_DISCONNECTED use in fs/nfs/dir.c that I was
hoping could be eliminated.  It was added by Al with
d9e80b7de91db05c1c4d2e5ebbfd70b3b3ba0e0f.  It looks totally theoretical
to me (nfs isn't exportable, hence shouldn't see DCACHE_DISCONNECTED
dentries), but maybe I'm missing something.

At a minimum maybe we could pull a comment out of Al's commit?:

--b.

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f430057..b96c687 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1194,6 +1194,12 @@ out_zap_parent:
 		/* If we have submounts, don't unhash ! */
 		if (have_submounts(dentry))
 			goto out_valid;
+		/*
+		 * We can't d_drop the root of a disconnected tree:
+		 * its d_hash is on the s_anon list and d_drop() would hide
+		 * it from shrink_dcache_for_unmount(), leading to busy
+		 * inodes on unmount and further oopses.
+		 */
 		if (dentry->d_flags & DCACHE_DISCONNECTED)
 			goto out_valid;
 		shrink_dcache_parent(dentry);
