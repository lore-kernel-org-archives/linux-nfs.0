Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33176 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932132AbcJGSql (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 14:46:41 -0400
Date: Fri, 7 Oct 2016 14:46:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5] NFSD: Add support for the COPY operation
Message-ID: <20161007184639.GA25120@fieldses.org>
References: <20160907195730.26480-1-Anna.Schumaker@Netapp.com>
 <20160909195336.GA25490@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160909195336.GA25490@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 09, 2016 at 03:53:36PM -0400, J. Bruce Fields wrote:
> On Wed, Sep 07, 2016 at 03:57:29PM -0400, Anna Schumaker wrote:
> > This patch adds server support for the NFS v4.2 COPY operation.  I did some
> > performance testing on my own, and found that a 4MB copy cap has performance
> > pretty close to copying with no cap at all.  Here are my results for testing
> > with various file sizes and copy caps:
> 
> Thanks, but we expect the tradeoffs here to vary a lot depending on the
> latency of the client<->server connection and the server<->server copy
> bandwidth.  So this isn't really interesting without knowing your
> testing setup.

... but I guess I'm inclined to try this anyway.  It's simple.  We can
do something more complicated later if this turns out to be a problem.

Maybe it'd help to leave a little more documentation here.

Applying for 4.8 with that change.

--b.

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 271a23cf6470..8ca642fe9b21 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -516,7 +516,15 @@ __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
 ssize_t nfsd_copy_file_range(struct file *src, u64 src_pos, struct file *dst,
 			     u64 dst_pos, u64 count)
 {
-	/* Arbitrary 4 megabyte copy cap */
+
+	/*
+	 * Limit copy to 4MB to prevent indefinitely blocking an nfsd
+	 * thread and client rpc slot.  The choice of 4MB is somewhat
+	 * arbitrary.  We might instead base this on r/wsize, or make it
+	 * tunable, or use a time instead of a byte limit, or implement
+	 * asynchronous copy.  In theory a client could also recognize a
+	 * limit like this and pipeline multiple COPY requests.
+	 */
 	count = min_t(u64, count, 1 << 22);
 	return vfs_copy_file_range(src, src_pos, dst, dst_pos, count, 0);
 }
