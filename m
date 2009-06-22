From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/5] NFS private namespace patchset
Date: Mon, 22 Jun 2009 12:40:33 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0906221238370.3240@localhost.localdomain>
References: <20090622190913.27923.31665.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090622190913.27923.31665.stgit@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Al? Where are you?

I'd like to get ack's on Trond's series, and I'd also like to get an ack 
(or nak) on the (partly related) possible leak in the nd.root path 
reference leak.

Trond - the series looks fine to me, and I guess I'll apply it even 
without Al's acks, but I'd give it a day or two still..

		Linus

On Mon, 22 Jun 2009, Trond Myklebust wrote:
>
> The following series is a resend of a set of patches that were
> originally targetted for inclusion in 2.6.30-rc1. They build upon
> Al Viro's "Cache root in nameidata" patches, and add the ability to
> create a private mount namespace that is not visible to user
> processes.
> As stated before, the goal is to allow reuse of vfs_path_lookup() in
> order to allow the nfs client to walk down NFSv4 mount paths, and locate
> the directory that needs to be mounted.
> 
> There have been no further comments on these patches since I mailed the
> last revision, so I'm hoping that Al and Christoph will ack them and
> that Linus will apply...
> 
> Cheers
>   Trond
> 
> ---
> 
> Trond Myklebust (5):
>       NFS: Correct the NFS mount path when following a referral
>       NFS: Fix nfs_path() to always return a '/' at the beginning of the path
>       NFSv4: Replace nfs4_path_walk() with VFS path lookup in a private namespace
>       VFS: Add VFS helper functions for setting up private namespaces
>       VFS: Uninline the function put_mnt_ns()
> 
> 
>  fs/namespace.c                |   53 +++++++++--
>  fs/nfs/namespace.c            |    5 +
>  fs/nfs/super.c                |  202 +++++++++++++++++++++++++++++++++++++----
>  include/linux/mnt_namespace.h |   10 --
>  4 files changed, 231 insertions(+), 39 deletions(-)
> 
> -- 
> Signature
> 
