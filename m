From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC PATCH 0/2] Add VFS support for looking up paths on remote
	servers using a temporary mount namespace
Date: Tue, 10 Feb 2009 10:58:20 -0500
Message-ID: <20090210155820.GB29075@fieldses.org>
References: <20090209184534.23040.82605.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40239 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbZBJP6N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Feb 2009 10:58:13 -0500
In-Reply-To: <20090209184534.23040.82605.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 09, 2009 at 01:45:34PM -0500, Trond Myklebust wrote:
> The following two patches attempt to improve NFSv4's ability to look up
> the mount path on a remote server.
> 
> The first patch adds VFS support for walking the remote path, using a
> temporary mount namespace to represent the server's namespace, so that
> symlinks

I'm a bit confused about the symlink case--I take it you're assuming
that symlinks in the pseudofs should be interpreted as relative to the
server's namespace (in keeping with traditional implementations of
server exports), while symlinks elsewhere should continue to be
intepreted relative to the client's namespace.

Do the rfc's say anything about this?

--b.

> and referrals can be followed across remote filesystem and
> server boundaries.
> The second patch then uses this VFS helper in the NFSv4 mount code.
> 
> A later set of patches will clean out the legacy nfs4_path_walk, however
> I'm hoping for some commentary from the VFS folks on whether or not this
> approach is acceptable before I continue.
> 
> Cheers
>   Trond
> 
> ---
> 
> Trond Myklebust (2):
>       NFSv4: Use vfs_path_lookup() instead of nfs4_path_walk()
>       VFS: Add a VFS helper function vfs_remote_path_lookup()
> 
> 
>  fs/namei.c                    |   75 ++++++++++++++++++++-
>  fs/namespace.c                |   56 +++++++++++++--
>  fs/nfs/super.c                |  149 +++++++++++++++++++++++++++++++++++------
>  include/linux/mnt_namespace.h |    2 +
>  include/linux/namei.h         |    2 +
>  include/linux/nsproxy.h       |    1 
>  kernel/nsproxy.c              |   11 +++
>  7 files changed, 267 insertions(+), 29 deletions(-)
> 
> -- 
> Signature
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
