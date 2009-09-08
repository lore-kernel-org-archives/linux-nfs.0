From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] Support "-t nfs,vers=4" mounts in the kernel [take
 4]
Date: Tue, 08 Sep 2009 14:51:33 -0400
Message-ID: <4AA6A7B5.1060301@RedHat.com>
References: <20090902135032.3550.23170.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13813 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751111AbZIHSvj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2009 14:51:39 -0400
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
Trond,

I'm updating the mount.nfs man pages, and would like give 
an guess-ta-mate as to which kernel these patches will be in.
Any ideas?

steved.
