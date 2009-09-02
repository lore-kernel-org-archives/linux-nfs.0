From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] Support "-t nfs,vers=4" mounts in the kernel [take
 4]
Date: Wed, 02 Sep 2009 11:10:38 -0400
Message-ID: <4A9E8AEE.5040906@RedHat.com>
References: <20090902135032.3550.23170.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751384AbZIBPS1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Sep 2009 11:18:27 -0400
In-Reply-To: <20090902135032.3550.23170.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/02/2009 09:51 AM, Chuck Lever wrote:
> Sorry for the repost.  After reading the patch descriptions again, I
> thought they needed some clarification.
> 
> ---
> 
> Chuck Lever (4):
>       NFS: Allow the "nfs" file system type to support NFSv4
>       NFS: Move details of nfs4_get_sb() to a helper
>       NFS: Refactor NFSv4 text-based mount option validation
>       NFS: Mount option parser should detect missing "port="
> 
> 
>  fs/nfs/internal.h    |   10 ++
>  fs/nfs/super.c       |  202 +++++++++++++++++++++++++++++++++-----------------
>  include/linux/nfs4.h |    1 
>  3 files changed, 144 insertions(+), 69 deletions(-)
> 
Trond, is there an ETA on this? 

</rant>
We've turned a simple 2 patch solution into a 4 user
space patches and 4 kernel patches to simply added a
short cut to mount the nfs4 file system... If this not
an example of over engineering then I don't know what its...
</rant>


steved.
