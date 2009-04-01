From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/4] VFS: Add a VFS helper function
	vfs_remote_path_lookup()
Date: Wed, 1 Apr 2009 03:15:54 +0100
Message-ID: <20090401021554.GV28946@ZenIV.linux.org.uk>
References: <cover.1238525532.git.Trond.Myklebust@netapp.com> <3f1264127d431f695be25b940b477e3d287edc68.1238525532.git.Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, hch@infradead.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:33175 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339AbZDACQA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 22:16:00 -0400
In-Reply-To: <3f1264127d431f695be25b940b477e3d287edc68.1238525532.git.Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 11, 2009 at 03:50:33PM -0400, Trond Myklebust wrote:
> The purpose of this patch is to improve the mount path lookup support for
> filesystems such as NFSv4, which require you to look up a mount path
> string in a remote server's namespace.
> 
> Traversing such a path is pretty much identical to walking a local path,
> in that it may involve following symlinks and even following referrals to
> volumes that reside on other servers. Since the standard VFS path lookup
> code already supports all these features (using in-kernel automounts for
> following referrals) it would be nice to be able to reuse that code rather
> than special case the mount path lookup in the NFS client.
> 
> This patch therefore defines a VFS helper function that sets up a temporary
> mount namespace to represent the server namespace, and has the current
> task pivot into that prior to doing the path lookup. Upon completion, it
> pivots back into the original namespace, and destroys the private one.

NAK.  You are relying on too many things about caller (e.g. just what happens
if you have shared fs_struct?  Does caller guarantee it won't happen?), so
that's a bloody bad interface.  Open-code that sucker, then let's see what
to do with surrounding code.  As it stands - no.
