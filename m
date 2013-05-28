Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29423 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964871Ab3E1Rrl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 May 2013 13:47:41 -0400
Message-ID: <51A4EDB3.9070802@RedHat.com>
Date: Tue, 28 May 2013 13:47:31 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jan Stancek <jstancek@redhat.com>
CC: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] clnt_vc_control: fix VERS/PROG size
References: <6ed8842bb155fce40f3bb9283ba28e28c6432156.1368735469.git.jstancek@redhat.com>
In-Reply-To: <6ed8842bb155fce40f3bb9283ba28e28c6432156.1368735469.git.jstancek@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 16/05/13 16:25, Jan Stancek wrote:
> Following commit converted some operations to use memcpy, but the size
> of copied areas is now u_long, previously it was u_int32_t:
>   commit fac3eb51c7055055bdd7dccd9db556d9e4a1cf35
>   Author: Steve Dickson <steved@redhat.com>
>   Date:   Tue Feb 12 14:26:31 2013 -0500
>       clnt_vc_control: Removed a strict-aliasing warning
> 
> This broke mount on ppc64/s390x:
>   # ./mount.nfs -vvv -onfsvers=3,tcp rhel6-nfs:/export/home /mnt/test
>   mount.nfs: timeout set for Fri May  3 15:20:14 2013
>   mount.nfs: trying text-based options 'nfsvers=3,tcp,addr=10.1.1.5'
>   mount.nfs: prog 100003, trying vers=3, prot=6
>   mount.nfs: portmap query failed: RPC: Program/version mismatch
>   mount.nfs: Protocol not supported
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
Committed....

steved.

> ---
>  src/clnt_vc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/src/clnt_vc.c b/src/clnt_vc.c
> index 7769809..2eab9e4 100644
> --- a/src/clnt_vc.c
> +++ b/src/clnt_vc.c
> @@ -505,7 +505,7 @@ clnt_vc_control(cl, request, info)
>  	sigset_t newmask;
>  	int rpc_lock_value;
>  	u_int32_t tmp;
> -	u_long ltmp;
> +	u_int32_t ltmp;
>  
>  	assert(cl != NULL);
>  
> 
