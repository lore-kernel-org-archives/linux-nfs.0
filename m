Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49300 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758753Ab1FVTMm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 15:12:42 -0400
Date: Wed, 22 Jun 2011 20:12:40 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: [nfs, rpc] crap with refcounting and rmmod races
Message-ID: <20110622191239.GD11521@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

	There's something seriously screwed up with nfs4_closedata and
path_get()/path_put() in nfs4_do_close()/nfs4_free_closedata().

	Look: either we never call the latter before all preexisting
references to data->path.mnt are dropped, in which case we don't
need to grab/put the damn thing at all.  *OR* it is possible, in
which case that data->path.mnt might be the only thing that still
holds nfs.ko pinned down and right after the path_put() we might
be running code in a module with refcount 0.  Which is not a good
thing...

	Note that extra references to vfsmount do not prevent umount from
removing the sucker from the tree and dropping the preexisting reference
to it.  umount -l will do that just fine.

	This thing is called as ->rpc_release(); do we have anything
protecting the issuer of rpc_run_task() from being rmmod'ed before (or
during) the call of ->rpc_release()?
