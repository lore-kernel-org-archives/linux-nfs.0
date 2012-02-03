Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51021 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757690Ab2BCVKB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 16:10:01 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Provide vfs support for NFSv4 delegations
Date: Fri,  3 Feb 2012 16:09:51 -0500
Message-Id: <1328303397-3872-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20120203205818.GE2999@fieldses.org>
References: <20120203205818.GE2999@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches provide vfs support for NFSv4 delegations.

If they look sane then I'd like to get some version of them merged into
3.4.  I'm assuming Al would be the one to do that.

Currently nfsd implements delegations as leases.  However, leases don't
have quite the same semantics, which means that delegations are
currently enforced correctly only for conflicts between NFSv4 clients.

So, I define a new FL_DELEG flag to mark NFSv4 delegations.  In most
respects delegations behave just like leases, but they need to be broken
on more operations.

Delegations aren't exposed to userspace; nfsd is the only user.

In theory this code allows both read and write delegations, but I'm only
using read delegations for now--write delegations are a project for
another day.  (At which point write leases will probably need some
fixing too, while we're at it.)

--b.

