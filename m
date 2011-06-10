Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46621 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754972Ab1FJAJr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jun 2011 20:09:47 -0400
Date: Thu, 9 Jun 2011 20:09:44 -0400
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Christoph Hellwig <hch@infradead.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>, Eric Paris <eparis@redhat.com>
Subject: lease/delegation/oplock semantics
Message-ID: <20110610000944.GC22215@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Resending with some extra cc's, hope that's OK:

NFSv4 (along with, from what I'm told, Samba) has a problem with read
leases, which is that they are currently only broken on write opens,
whereas they should really be broken on any operation that changes an
inode's metadata or any of the links pointing to it.

Also, to break leases in a non-racy way it's not sufficient to have a
single break_lease() call from the vfs code; we also need to prevent
anyone from acquiring a new lease while the operation is still in
progress.

So here's one attempt to deal with those problems, by adding to the
inode a counter which is incremented whenever we start such an operation
and decremented when we finish it.

I only handle unlink; we'd also need to do link, rename, chown, and
chmod, at least.

Comments? Better ideas?

--b.
