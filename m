Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:47358 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726008AbeIESkh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 14:40:37 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [nfs-utils PATCH] statd: fix use-after-free in monitor list if
 insertion fails
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <d93ed8c0-0f17-4671-a852-8cea6330f5ba@redhat.com>
Date: Wed, 5 Sep 2018 10:10:00 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E4E29DD9-154E-4AFD-AD82-AF0F7E9DC1CC@oracle.com>
References: <d93ed8c0-0f17-4671-a852-8cea6330f5ba@redhat.com>
To: Frank Sorenson <sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Sep 1, 2018, at 2:07 AM, Frank Sorenson <sorenson@redhat.com> wrote:
> 
> If nsm_insert_monitored_host() fails while saving the record to
> stable storage, we can't just assume the entry was new. Existing
> records must be removed from the list before being freed.
> 
> Signed-off-by: Frank Sorenson <sorenson@redhat.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
> index 45c4346..9400048 100644
> --- a/utils/statd/monitor.c
> +++ b/utils/statd/monitor.c
> @@ -197,7 +197,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
> 
> 	if (!nsm_insert_monitored_host(dnsname,
> 				(struct sockaddr *)(char *)&my_addr, argp)) {
> -		nlist_free(NULL, clnt);
> +		nlist_free(existing ? &rtnl : NULL, clnt);
> 		goto failure;
> 	}
> 

--
Chuck Lever
