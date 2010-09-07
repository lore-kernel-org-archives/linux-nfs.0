Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49882 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932379Ab0IGR5t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 13:57:49 -0400
Message-ID: <4C867D14.4000203@RedHat.com>
Date: Tue, 07 Sep 2010 13:57:40 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] Handle "proto=rdma" regressions
References: <20100907162156.3392.90376.stgit@seurat.1015granger.net>
In-Reply-To: <20100907162156.3392.90376.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/07/2010 12:25 PM, Chuck Lever wrote:
> Steve-
> 
> This series is entirely untested, and is meant to be only an example
> of how we could handle "proto=rdma" and "rdma" in mount.nfs.
> 
> The last patch in the series may not work at all.  It depends on the
> kernel returning EPROTONOSUPPORT for "vers=4,rdma".
> 
> ---
> 
> Chuck Lever (4):
>       mount.nfs: Prepare way for "vers=4,rdma" mounts
>       mount.nfs: Support an "rdma" mount option
>       mount.nfs: Use nfs_nfs_protocol() for checking for proto=rdma
>       getport: Recognize "rdma" and "rdma6" netid
> 
> 
>  support/include/nfsrpc.h |    6 ++++++
>  support/nfs/getport.c    |   25 +++++++++++++++++++++++++
>  utils/mount/network.c    |    9 +++++++--
>  utils/mount/nfs.man      |   11 ++++++++++-
>  utils/mount/stropts.c    |   16 ++++++++--------
>  5 files changed, 56 insertions(+), 11 deletions(-)
> 
With all due respect... NACK.... Here is why...

1) RDMA is not a network protocol and as I found out this
   weekend it *never* be one, so I see absolutely no reason 
   to treat RDMA like something it will never be. So using 
   nfs_nfs_protocol() is incorrect. 
 
2) Instead of modifying a couple if statements you are
   now making it a two step process to handle RDMA mount,
   which is not simpler.

3) Due to potential problems with callback with v4 the default
   version needs to be v3. But I do feel allowing the version
   to be set on the command line should work....

One thing that has become very apparent to me is, RDMA
is not a network protocol and its not even a well defined 
netid. RDMA a special case (to use your words) so that is
they way we should treated.. 

I will merge your man page changes as well as the comments I 
promised and repost the simpler, one routine patch... 

steved.


