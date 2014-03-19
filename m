Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2843 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933610AbaCSMnk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2014 08:43:40 -0400
Message-ID: <53298930.3090806@RedHat.com>
Date: Wed, 19 Mar 2014 08:10:24 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFSv4: Ensure we respect soft mount timeouts during
 trunking discovery
References: <1395173006-14871-1-git-send-email-trond.myklebust@primarydata.com> <1395173006-14871-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1395173006-14871-2-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/18/2014 04:03 PM, Trond Myklebust wrote:
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Tested-by: Steve Dickson <steved@redhat.com>

steved.
> ---
>  fs/nfs/nfs4state.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index f544a1560c83..2349518eef2c 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2075,8 +2075,10 @@ again:
>  	switch (status) {
>  	case 0:
>  		break;
> -	case -NFS4ERR_DELAY:
>  	case -ETIMEDOUT:
> +		if (clnt->cl_softrtry)
> +			break;
> +	case -NFS4ERR_DELAY:
>  	case -EAGAIN:
>  		ssleep(1);
>  	case -NFS4ERR_STALE_CLIENTID:
> 
