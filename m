Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60576 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab3IIHpo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Sep 2013 03:45:44 -0400
Date: Mon, 9 Sep 2013 00:45:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/4] dcache: don't clear DCACHE_DISCONNECTED too early
Message-ID: <20130909074540.GA21076@infradead.org>
References: <1378579561-26868-1-git-send-email-bfields@redhat.com>
 <1378579561-26868-5-git-send-email-bfields@redhat.com>
 <20130909004647.GK13318@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130909004647.GK13318@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 09, 2013 at 01:46:47AM +0100, Al Viro wrote:
> On Sat, Sep 07, 2013 at 02:46:01PM -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > DCACHE_DISCONNECTED should not be cleared until we're sure the dentry is
> > connected all the way up to the root of the filesystem.  It *shouldn't*
> > be cleared as soon as the dentry is connected to a parent.  That will
> > cause bugs at least on exportable filesystems.
> 
> Then you probably want this
>                 if (!IS_ROOT(pd)) {
>                         /* must have found a connected parent - great */
>                         spin_lock(&pd->d_lock);
>                         pd->d_flags &= ~DCACHE_DISCONNECTED;
>                         spin_unlock(&pd->d_lock);
>                         noprogress = 0;
> to go through all intermediates, clearing DCACHE_DISCONNECTED on all of
> them; O(depth^2) can suck when we have a long chain of directories...

Aka call reconnect_path() from fs/exportfs/expfs.c on it.

