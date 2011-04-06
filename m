From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] Three short subjects for nfs-utils
Date: Wed, 06 Apr 2011 11:10:01 -0400
Message-ID: <4D9C8249.8070906@RedHat.com>
References: <20110325213559.27166.71461.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28271 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755952Ab1DFPKE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 11:10:04 -0400
In-Reply-To: <20110325213559.27166.71461.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/25/2011 05:37 PM, Chuck Lever wrote:
> Hi Steve-
> 
> Here are two minor bug fixes, and a mountd clean up that will help out
> with FedFS down the road.  No hurry.
> 
> ---
> 
> Chuck Lever (2):
>       statd: Remove vestigial "-w" option from man page synopsis
>       mount.nfs: Don't leak socket in nfs_ca_sockname()
> 
> Trond Myklebust (1):
>       exports: add a configurable time-to-live for the kernel cache entries
> 
> 
>  support/include/exportfs.h |    1 +
>  support/include/nfslib.h   |    1 +
>  support/nfs/exports.c      |    1 +
>  utils/mount/network.c      |   28 +++++++++++++---------------
>  utils/mountd/cache.c       |   15 ++++++++-------
>  utils/statd/statd.man      |    2 +-
>  6 files changed, 25 insertions(+), 23 deletions(-)
> 
All three patches committed...

steved.
