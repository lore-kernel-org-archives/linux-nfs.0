Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57425 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102Ab2EISPP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 14:15:15 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q49IFFQM015171
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 9 May 2012 14:15:15 -0400
Message-ID: <4FAAB41D.70801@RedHat.com>
Date: Wed, 09 May 2012 14:14:53 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsdcld: demote pipe opening error to D_GENERAL
References: <1336508786-2531-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1336508786-2531-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/08/2012 04:26 PM, Jeff Layton wrote:
> It's actually expected that this will fail initially when we start the
> daemon. Until knfsd has been started, the pipe doesn't exist, and we
> generally want to start nfsdcld before starting knfsd.
> 
> Avoid the scary error message by demoting this message to D_GENERAL.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed...

steved.
> ---
>  utils/nfsdcld/nfsdcld.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
> index f4e9502..e7af4e3 100644
> --- a/utils/nfsdcld/nfsdcld.c
> +++ b/utils/nfsdcld/nfsdcld.c
> @@ -138,7 +138,7 @@ cld_pipe_open(struct cld_client *clnt)
>  	xlog(D_GENERAL, "%s: opening upcall pipe %s", __func__, pipepath);
>  	fd = open(pipepath, O_RDWR, 0);
>  	if (fd < 0) {
> -		xlog(L_ERROR, "%s: open of %s failed: %m", __func__, pipepath);
> +		xlog(D_GENERAL, "%s: open of %s failed: %m", __func__, pipepath);
>  		return -errno;
>  	}
>  
