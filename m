Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42675 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753286Ab0IIOup (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 10:50:45 -0400
Message-ID: <4C88F442.7020808@RedHat.com>
Date: Thu, 09 Sep 2010 10:50:42 -0400
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
The testing when well... v4 is the default version on RDMA
mounts... 

Committed...

steved.
