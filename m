Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:36841 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316AbcDXMqU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Apr 2016 08:46:20 -0400
Received: by mail-qg0-f52.google.com with SMTP id d90so41379729qgd.3
        for <linux-nfs@vger.kernel.org>; Sun, 24 Apr 2016 05:46:19 -0700 (PDT)
Message-ID: <1461501975.5219.40.camel@poochiereds.net>
Subject: Re: parallel lookups on NFS
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>, linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 24 Apr 2016 08:46:15 -0400
In-Reply-To: <20160424023453.GK25498@ZenIV.linux.org.uk>
References: <20160424023453.GK25498@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2016-04-24 at 03:34 +0100, Al Viro wrote:
> 	There's a fun problem - for all the complaints about evil, crude
> VFS exclusion not letting the smart filesystem developers Do It Right(tm),
> NFS has a homegrown kinda-sorta rwsem, with delayed unlinks being readers
> and lookups - writers.
> 
> 	IOW, nfs_block_sillyrename() still yields lookup/lookup exclusion,
> even with ->i_mutex replaced with rwsem and ->lookup() calls happening in
> parallel.  What's more, the thing is very much writer(==lookup)-starving.
> 
> 	What kind of ordering do we really want there?  Existing variant
> is very crude - lookups (along with readdir and atomic_open) are writers,
> delayed unlinks - readers, and there's no fairness whatsoever; if delayed
> unlink comes during lookup, it is put on a list and once lookup is done,
> everything on that list is executed.  Moreover, any unlinks coming during
> the execution of those are executed immediately.  And no lookup (in that
> directory) is allowed until there's no unlinks in progress.
> 
> 	Creating a storm of delayed unlinks isn't hard - open-and-unlink
> a lot, then exit and you've got it...
> 
> 	Suggestions?  Right now my local tree has nfs_lookup() and
> nfs_readdir() run with directory locked shared.  And they are still
> serialized by the damn ->silly_count ;-/
> 

Hmm...well, most of that was added in commit 565277f63c61. Looking at
the bug referenced in that commit log, I think that the main thing we
want to ensure is that rmdir waits until all of the sillydeletes for
files in its directory have finished.

But...there's also some code to ensure that if a lookup races in while
we're doing the sillydelete that we transfer all of the dentry info to
the new alias. That's the messy part.

The new infrastructure for parallel lookups might make it simpler
actually. When we go to do the sillydelete, could we add the dentry to
the "lookup in progress" hash that you're adding as part of the
parallel lookup infrastructure? Then the tasks doing lookups could find
it and just wait on the sillydelete to complete. After the sillydelete,
we'd turn the thing into a negative dentry and then wake up the waiters
(if any). That does make the whole dentry teardown a bit more complex
though.

OTOH...Al, I think you mentioned at one time that you thought the whole
sillydelete mechanism was overly-complicated, and that it might be
cleaner to do this somehow in f_op->release? I don't recall the details
of what you had in mind at the time, but it might be good to rethink
the whole mess.

> 	Incidentally, why does nfs_complete_unlink() recheck ->d_flags?
> The caller of ->d_iput() is holding the only reference to dentry; who and
> what could possibly clear DCACHE_NFSFS_RENAMED between the checks in
> nfs_dentry_iput() and nfs_complete_unlink()?

Yeah, that looks superfluous. I imagine that can be removed.

-- 
Jeff Layton <jlayton@poochiereds.net>
