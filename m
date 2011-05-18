Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38850 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933451Ab1ERTTv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 15:19:51 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: fixing leases/delegations
Date: Wed, 18 May 2011 15:19:46 -0400
Message-Id: <1305746388-18241-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

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
