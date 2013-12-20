Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54498 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932823Ab3LTNZY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Dec 2013 08:25:24 -0500
Message-Id: <20131220131635.650823732@bombadil.infradead.org>
Date: Fri, 20 Dec 2013 05:16:35 -0800
From: Christoph Hellwig <hch@infradead.org>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, Mark Fasheh <mfasheh@suse.com>,
        Joel Becker <jlbec@evilplan.org>, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, jfs-discussion@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
Subject: [PATCH 00/21] Consolidate Posix ACL implementation V3
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series consolidates the various cut'n'pasted Posix ACL implementations
into a single common one based on the ->get_acl method Linus added a while
ago and a new ->set_acl counterpart.

This remove ~1800 lines of code and provides a single place to implement
various nasty little gems of the semantics.

Unfortunately the 9p code is still left out - it implements the ACLs
in two very weird ways, one using the common code but on the client only,
and one pasing things straight through to the server.  We could easily
convert it to the new code on the write side if ->set_acl took a dentry,
but there's no cance to do that on the ->get_acl side.  Ideas how to
handle it welcome.

After that we'd be ready to never go into the fs for the ACL attributes
and branch straight to the ACL code below the syscall, repairing the
old API braindamage of overloading ACLs onto the xattrs.


Changes from V2:
 - remove redundant S_ISLNK checks
 - fix the get_acl return value
 - remove spurious symlink get_acl instance in gfs2
 - fix default ACL inheritance on NFS
 - use get_acl and set_acl from the NFS server
 - remove some incorrectly copy&pasted code in hfsplus

Changes from V1:
 - check for symlinks in the ACL code and remove checks in the lower
   level functions.
 - remove get_acl instances for symlinks in a few filesystems
 - pass a umode_t mode argument to posix_acl_chmod to accomodate f2fs
 - various cosemtic bits from the reviews.

Note that I still haven't heard from ocfs2 folks, so the patch is left
unchanged.

------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
_______________________________________________
Jfs-discussion mailing list
Jfs-discussion@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/jfs-discussion
