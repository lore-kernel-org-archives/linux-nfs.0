Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59097 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751764Ab1IUO62 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 10:58:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: breaking leases on metadata changes
Date: Wed, 21 Sep 2011 10:58:11 -0400
Message-Id: <1316617097-21384-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

So there's this longstanding problem that read leases should really be
broken on anything that changes an inode's metadata or any change to the
set of links pointing to the inode.

(Cc'ing samba-technical for confirmation of that statement from Samba's
point of view....)

So we need mutual exclusion between read leases and link, unlink,
rename, etc.

After contemplating increasingly complicated solutions for much too
long, I realized that the i_mutex is taken by all of those operations
except for rename--and it looks to me like rename could take i_mutex on
a renamed file as well.

So, here's my attempt.  It passes some simple tests.  Is it sane?

I tried updating Documentation/filesystems/directory-locking to reflect
the rename change, but without thinking it through as carefully as I'd
like to.

Also, the one thing I *know* is wrong: lockdep doesn't like the rename
change, and I haven't tried to figure out how to fix it.  (Help?)

These patches assume some previous lease fixes already committed to

	git://linux-nfs.org/~bfields/linux.git for-3.2

--b.
