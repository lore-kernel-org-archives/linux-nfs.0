From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/7] The final patches for mountd IPv6 support
Date: Tue, 28 Sep 2010 08:08:09 -0400
Message-ID: <4CA1DAA9.9080809@RedHat.com>
References: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48493 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750787Ab0I1MIM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 08:08:12 -0400
In-Reply-To: <20100920162616.3170.24625.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/20/2010 12:32 PM, Chuck Lever wrote:
> Hi Steve-
> 
> Here's the last set of patches implementing basic IPv6 support for
> mountd.  This set enables mountd to listen on IPv6 transports, if they
> are available.
> 
> I've done a little re-arranging of Neil's recent changes to control
> the MNT version, in order to make my changes easier; hopefully you
> guys won't mind that.
> 
> Also included here is an overhaul of rpc.mountd(8).
> 
> As a last step, I enable IPv6 support in rpc.nfsd again.  This should
> make NFS server-side IPv6 support, in both user space and in the
> kernel, complete.
> 
> I'm sure there will be bug fixes, but hopefully this is the last of
> these for a while.
> 
> ---
> 
> Chuck Lever (7):
>       nfsd: Enable IPv6 support in rpc.nfsd again.
>       mountd: Update mountd/exportfs man pages to reflect IPv6 changes
>       mountd: Use MNT status values instead of NFSERR
>       mountd: Fix up version and usage messages
>       mountd: Unregister mountd if my_svc_run() returns
>       mountd: Support TI-RPC mountd listener
>       mountd: Make NFS version checks more strict
> 
> 
>  utils/exportfs/exportfs.man |  287 ++++++++++++++++++++++---------------------
>  utils/exportfs/exports.man  |   88 ++++++++-----
>  utils/mountd/mountd.c       |  136 ++++++++++++++------
>  utils/mountd/mountd.man     |  240 +++++++++++++++++++++++-------------
>  utils/nfsd/nfsd.c           |    9 -
>  utils/nfsd/nfssvc.c         |    9 -
>  6 files changed, 445 insertions(+), 324 deletions(-)
> 
All seven committed... 

steved.
