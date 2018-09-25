Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56526 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729306AbeIYVwI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Sep 2018 17:52:08 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1F2073081256
        for <linux-nfs@vger.kernel.org>; Tue, 25 Sep 2018 15:44:03 +0000 (UTC)
Subject: Re: [PATCH] getnetconfig.c: fix a BAD_FREE (CWE-763)
To: Zhi Li <yieli@redhat.com>, linux-nfs@vger.kernel.org
References: <1537863212-1389-1-git-send-email-yieli@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <00c09492-70b0-0891-1f3c-318e8b787781@RedHat.com>
Date: Tue, 25 Sep 2018 11:44:02 -0400
MIME-Version: 1.0
In-Reply-To: <1537863212-1389-1-git-send-email-yieli@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 9/25/18 4:13 AM, Zhi Li wrote:
> Signed-off-by: Zhi Li <yieli@redhat.com>
> ---
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=1631614
> 
>  src/getnetconfig.c | 17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/src/getnetconfig.c b/src/getnetconfig.c
> index d67d97d..869556d 100644
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
> @@ -700,12 +701,12 @@ struct netconfig	*ncp;
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
>  	free(p->nc_netid);
Ok... I see why tmp original value needs to be maintained 
to do the free()... but I'm wondering why the freeing 
of p->nc_netid is needed... it appears to me it is part
of tmp string... so when tmp is freed won't p->nc_netid
be freed as well?

steved.


> @@ -714,8 +715,8 @@ struct netconfig	*ncp;
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
