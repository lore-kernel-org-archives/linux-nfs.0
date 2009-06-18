From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/4] NFS private namespace patchset
Date: Thu, 18 Jun 2009 12:40:21 -0700
Message-ID: <1245354021.8756.43.camel@heimdal.trondhjem.org>
References: <20090618192500.19433.16770.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:45336 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752644AbZFRTk3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jun 2009 15:40:29 -0400
In-Reply-To: <20090618192500.19433.16770.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-06-18 at 12:25 -0700, Trond Myklebust wrote:
> The following series is a resend of a set of patches that were originally
> targetted for inclusion in 2.6.30-rc1. They build upon Al Viro's "Cache
> root in nameidata" patches, and add the ability to create a private
> mount namespace that is not visible to user processes.

Sorry: 'resend' is probably a bit strong. The first patch has been
modified following our discussions at the filesystem and storage summit,
and the second has changed so as to use this interface...

> As stated before, the goal is to allow reuse of vfs_path_lookup() in
> order to allow the nfs client to walk down NFSv4 mount paths, and locate
> the directory that needs to be mounted.
> 
> Cheers
>   Trond
> 
> ---
> 
> Trond Myklebust (4):
>       NFS: Correct the NFS mount path when following a referral
>       NFS: Fix nfs_path() to always return a '/' at the beginning of the path
>       NFSv4: Replace nfs4_path_walk() with VFS path lookup in a private namespace
>       VFS: Add VFS helper functions for setting up private namespaces
> 
> 
>  fs/namespace.c                |   46 ++++++++-
>  fs/nfs/namespace.c            |    5 +
>  fs/nfs/super.c                |  202 +++++++++++++++++++++++++++++++++++++----
>  include/linux/mnt_namespace.h |    1 
>  4 files changed, 225 insertions(+), 29 deletions(-)
> 


