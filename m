Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:36930 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383Ab3ISLBz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Sep 2013 07:01:55 -0400
Date: Thu, 19 Sep 2013 12:01:47 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: Milosz Tanski <milosz@adfin.com>, Trond.Myklebust@netapp.com,
        jlayton@redhat.com, moseleymark@gmail.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: evict_inode() vs iget5_locked() race [was Re: [Linux-cachefs]
 Blast from the past, CacheFiles: Error: Unexpected object collision]
Message-ID: <20130919110147.GQ13318@ZenIV.linux.org.uk>
References: <CANP1eJE=T4PPPBcvs4vj--zNMtkvRGqiAjR2ZfZuA0=DVGYA6A@mail.gmail.com>
 <5769.1379579209@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5769.1379579209@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 19, 2013 at 09:26:49AM +0100, David Howells wrote:

> There's a potential race between evict_inode() and iget5_locked() in which the
> former can be tearing down an inode corresponding to a file whilst the latter
> is trying to set up a new inode corresponding to that same file - but it's
> possible that the cleanups for the former may adversely affect the setups for
> the latter.

evict() calls ->evict_inode() before removing it from hash.  It's called
only with I_FREEING already set.  If find_inode() runs across that
sucker, it will wait for evict() to do
	wake_up_bit(&inode->i_state, __I_NEW);
(after return from ->evict_inode() and after removal from hash chain)
and repeat the search.

Details, please...
