Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46814 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729073AbeIFTAF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Sep 2018 15:00:05 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D09DF8666D
        for <linux-nfs@vger.kernel.org>; Thu,  6 Sep 2018 14:24:18 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] statd: fix use-after-free in monitor list if
 insertion fails
To: Frank Sorenson <sorenson@redhat.com>, linux-nfs@vger.kernel.org
References: <d93ed8c0-0f17-4671-a852-8cea6330f5ba@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <7d2ce33d-8f08-6a15-b47f-824554477eb7@RedHat.com>
Date: Thu, 6 Sep 2018 10:24:16 -0400
MIME-Version: 1.0
In-Reply-To: <d93ed8c0-0f17-4671-a852-8cea6330f5ba@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/01/2018 02:07 AM, Frank Sorenson wrote:
> If nsm_insert_monitored_host() fails while saving the record to
> stable storage, we can't just assume the entry was new. Existing
> records must be removed from the list before being freed.
> 
> Signed-off-by: Frank Sorenson <sorenson@redhat.com>
Committed.... 

steved.
> 
> diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
> index 45c4346..9400048 100644
> --- a/utils/statd/monitor.c
> +++ b/utils/statd/monitor.c
> @@ -197,7 +197,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
>  
>  	if (!nsm_insert_monitored_host(dnsname,
>  				(struct sockaddr *)(char *)&my_addr, argp)) {
> -		nlist_free(NULL, clnt);
> +		nlist_free(existing ? &rtnl : NULL, clnt);
>  		goto failure;
>  	}
>  
> 
