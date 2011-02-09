Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46273 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893Ab1BIEz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 23:55:57 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1Pn25s-00040d-NP
	for linux-nfs@vger.kernel.org; Tue, 08 Feb 2011 23:55:56 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: Fix a 2.6.38 delegation regression
Date: Tue,  8 Feb 2011 23:55:45 -0500
Message-Id: <1297227351-15365-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When I removed the mylease callback for the 2.6.38 merge window, I
screwed up: I forgot that nfsd could hold multiple leases on the same
file on behalf of multiple clients, and that all those leases would be
associated with the same file descriptor.  This could cause a problem
when removing a lease, as the wrong lease could get removed.

There's no real reason why we should hold multiple leases; we can
instead just keep one lease, and use a count of the number of
delegations to decide when to remove it.

The following patches do that (after a little preperatory cleanup).

We could instead revert the mylease removal.  But I think this is still
a small enough change to justify after the merge window.  So barring
objections I intend to to submit this for 2.6.38 soon (along with a
couple other bugfixes I have queued up.)

--b.

