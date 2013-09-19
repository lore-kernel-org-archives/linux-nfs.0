Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751804Ab3ISI04 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 04:26:56 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CANP1eJE=T4PPPBcvs4vj--zNMtkvRGqiAjR2ZfZuA0=DVGYA6A@mail.gmail.com>
References: <CANP1eJE=T4PPPBcvs4vj--zNMtkvRGqiAjR2ZfZuA0=DVGYA6A@mail.gmail.com>
To: Milosz Tanski <milosz@adfin.com>, viro@ZenIV.linux.org.uk,
        Trond.Myklebust@netapp.com, jlayton@redhat.com
Cc: dhowells@redhat.com, moseleymark@gmail.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: evict_inode() vs iget5_locked() race [was Re: [Linux-cachefs] Blast from the past, CacheFiles: Error: Unexpected object collision]
Date: Thu, 19 Sep 2013 09:26:49 +0100
Message-ID: <5769.1379579209@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Milosz Tanski <milosz@adfin.com> wrote:

> I'm sure this is going to seam random but... I'm seeing the same error
> as you were in Sept of 2011 (I know) that you reported in the mailing
> list. The error steps from an debug check that reports:
> 
> CacheFiles: Error: Unexpected object collision
> 
> I know you reported that issue but I didn't see any follow up after
> that. Was there something that fixed the issue for you?
> 
> I'm impleting fscache for cephfs and I've ran into the same issue.

I think I've just found the cause of the cachefiles error.

There's a potential race between evict_inode() and iget5_locked() in which the
former can be tearing down an inode corresponding to a file whilst the latter
is trying to set up a new inode corresponding to that same file - but it's
possible that the cleanups for the former may adversely affect the setups for
the latter.

I'm guessing the VFS doesn't want to have to deal with dying inodes in
iget5_locked() - which means the fs has to handle it.

In terms of NFS, what I'm seeing is that NFS is asked to evict an inode which
has an fscache cookie attached (the ->evict_inode() sb op is called).  This
jumps into nfs_evict_inode() and thence into nfs_clear_inode() which calls
fscache_relinquish_cookie().

However, if nfs_fhget() then requests a new copy of the inode, iget5_locked()
will return a new one - even if evict_inode() is still busy tearing down the
old one.

Cachefiles then reports an error because it is still trying to dispose of the
old cache object when we get a request to reget it with a different cookie
(which we're not supposed to see - nfs_clear_inode() is delayed until
cachefiles has progressed sufficiently).

I can handle the cachefiles problem by making the new request wait for the
disposal of the old one to complete.

However, is it possible for truncate_inode_pages() in nfs/nfs4_evict_inode()
to be still attempting to do writeback at the time we're busy setting up a new

Also, is it possible for nfs4_evict_inode() to be trying to return a
delegation whilst another process is trying to get a delegation on the same
file?

David
