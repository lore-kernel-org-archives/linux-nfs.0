Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:49131 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab3IIAqt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Sep 2013 20:46:49 -0400
Date: Mon, 9 Sep 2013 01:46:47 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/4] dcache: don't clear DCACHE_DISCONNECTED too early
Message-ID: <20130909004647.GK13318@ZenIV.linux.org.uk>
References: <1378579561-26868-1-git-send-email-bfields@redhat.com>
 <1378579561-26868-5-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1378579561-26868-5-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 07, 2013 at 02:46:01PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> DCACHE_DISCONNECTED should not be cleared until we're sure the dentry is
> connected all the way up to the root of the filesystem.  It *shouldn't*
> be cleared as soon as the dentry is connected to a parent.  That will
> cause bugs at least on exportable filesystems.

Then you probably want this
                if (!IS_ROOT(pd)) {
                        /* must have found a connected parent - great */
                        spin_lock(&pd->d_lock);
                        pd->d_flags &= ~DCACHE_DISCONNECTED;
                        spin_unlock(&pd->d_lock);
                        noprogress = 0;
to go through all intermediates, clearing DCACHE_DISCONNECTED on all of
them; O(depth^2) can suck when we have a long chain of directories...
