Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37304 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725990AbeI0AWp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Sep 2018 20:22:45 -0400
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 657615F75D
        for <linux-nfs@vger.kernel.org>; Wed, 26 Sep 2018 18:08:37 +0000 (UTC)
Subject: Re: [PATCH-V2] [nfs/nfs-utils/libtirpc] src/getnetconfig.c: fix a
 BAD_FREE (CWE-763)
To: Zhi Li <yieli@redhat.com>, linux-nfs@vger.kernel.org
References: <1537932352-19537-1-git-send-email-yieli@redhat.com>
 <1537932352-19537-2-git-send-email-yieli@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <df0f1cea-f425-b3f5-bc10-a698612feced@RedHat.com>
Date: Wed, 26 Sep 2018 14:08:36 -0400
MIME-Version: 1.0
In-Reply-To: <1537932352-19537-2-git-send-email-yieli@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 9/25/18 11:25 PM, Zhi Li wrote:
> Signed-off-by: Zhi Li <yieli@redhat.com>
> ---
> From steved:
> Ok... I see why tmp original value needs to be maintained
> to do the free()... but I'm wondering why the freeing
> of p->nc_netid is needed... it appears to me it is part
> of tmp string... so when tmp is freed won't p->nc_netid
> be freed as well?
> 
> Reply:
> Yes, you are right, p->nc_neti is a part of tmp string, so freeing tmp can make p->nc_neti be freed as well.
> I have update the issue.
> 
>  src/getnetconfig.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
Committed... 

steved.

> 
> diff --git a/src/getnetconfig.c b/src/getnetconfig.c
> index d67d97d..cfd33c2 100644
> --- a/src/getnetconfig.c
> +++ b/src/getnetconfig.c
> @@ -681,6 +681,7 @@ struct netconfig	*ncp;
>  {
>      struct netconfig	*p;
>      char	*tmp;
> +    char	*t;
>      u_int	i;
>  
>      if ((tmp=malloc(MAXNETCONFIGLINE)) == NULL)
> @@ -700,22 +701,21 @@ struct netconfig	*ncp;
>       */
>      *p = *ncp;
>      p->nc_netid = (char *)strcpy(tmp,ncp->nc_netid);
> -    tmp = strchr(tmp, 0) + 1;
> -    p->nc_protofmly = (char *)strcpy(tmp,ncp->nc_protofmly);
> -    tmp = strchr(tmp, 0) + 1;
> -    p->nc_proto = (char *)strcpy(tmp,ncp->nc_proto);
> -    tmp = strchr(tmp, 0) + 1;
> -    p->nc_device = (char *)strcpy(tmp,ncp->nc_device);
> +    t = strchr(tmp, 0) + 1;
> +    p->nc_protofmly = (char *)strcpy(t,ncp->nc_protofmly);
> +    t = strchr(t, 0) + 1;
> +    p->nc_proto = (char *)strcpy(t,ncp->nc_proto);
> +    t = strchr(t, 0) + 1;
> +    p->nc_device = (char *)strcpy(t,ncp->nc_device);
>      p->nc_lookups = (char **)malloc((size_t)(p->nc_nlookups+1) * sizeof(char *));
>      if (p->nc_lookups == NULL) {
> -	free(p->nc_netid);
>  	free(p);
>  	free(tmp);
>  	return(NULL);
>      }
>      for (i=0; i < p->nc_nlookups; i++) {
> -    	tmp = strchr(tmp, 0) + 1;
> -    	p->nc_lookups[i] = (char *)strcpy(tmp,ncp->nc_lookups[i]);
> +	t = strchr(t, 0) + 1;
> +	p->nc_lookups[i] = (char *)strcpy(t,ncp->nc_lookups[i]);
>      }
>      return(p);
>  }
> 
