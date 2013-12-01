Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59164 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab3LAMG4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Dec 2013 07:06:56 -0500
Message-Id: <20131201115903.910559036@bombadil.infradead.org>
Date: Sun, 01 Dec 2013 03:59:03 -0800
From: Christoph Hellwig <hch@infradead.org>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, Mark Fasheh <mfasheh@suse.com>,
        Joel Becker <jlbec@evilplan.org>, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, jfs-discussion@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH 00/18] Consolidate Posix ACL implementation
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This series consolidates the various cut'n'pasted Posix ACL implementations
into a single common one based on the ->get_acl method Linus added a while
ago and a new ->set_acl counterpart.

This 1600 lines of code and provides a single place to implement various
nasty little gems of the semantics.

Unfortunately the 9p code is still left out - it implements the ACLs
in two very weird ways, one using the common code but on the client only,
and one pasing things straight through to the server.  We could easily
convert it to the new code on the write side if ->set_acl took a dentry,
but there's no cance to do that on the ->get_acl side.  Ideas how to
handle it welcome.

After that we'd be ready to never go into the fs for the ACL attributes
and branch straight to the ACL code below the syscall, repairing the
old API braindamage of overloading ACLs onto the xattrs.

Btw, I'd be almost tempted to do that for all system.* attrs.  Besides
Posix ACLs we only have CIFS and NFSv4 ACL variants, weird advice crap
in f2fs, and the magic mushroom proto name on sockets.
