Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:45365 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbcDXCe4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Apr 2016 22:34:56 -0400
Date: Sun, 24 Apr 2016 03:34:53 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: parallel lookups on NFS
Message-ID: <20160424023453.GK25498@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

	There's a fun problem - for all the complaints about evil, crude
VFS exclusion not letting the smart filesystem developers Do It Right(tm),
NFS has a homegrown kinda-sorta rwsem, with delayed unlinks being readers
and lookups - writers.

	IOW, nfs_block_sillyrename() still yields lookup/lookup exclusion,
even with ->i_mutex replaced with rwsem and ->lookup() calls happening in
parallel.  What's more, the thing is very much writer(==lookup)-starving.

	What kind of ordering do we really want there?  Existing variant
is very crude - lookups (along with readdir and atomic_open) are writers,
delayed unlinks - readers, and there's no fairness whatsoever; if delayed
unlink comes during lookup, it is put on a list and once lookup is done,
everything on that list is executed.  Moreover, any unlinks coming during
the execution of those are executed immediately.  And no lookup (in that
directory) is allowed until there's no unlinks in progress.

	Creating a storm of delayed unlinks isn't hard - open-and-unlink
a lot, then exit and you've got it...

	Suggestions?  Right now my local tree has nfs_lookup() and
nfs_readdir() run with directory locked shared.  And they are still
serialized by the damn ->silly_count ;-/

	Incidentally, why does nfs_complete_unlink() recheck ->d_flags?
The caller of ->d_iput() is holding the only reference to dentry; who and
what could possibly clear DCACHE_NFSFS_RENAMED between the checks in
nfs_dentry_iput() and nfs_complete_unlink()?
