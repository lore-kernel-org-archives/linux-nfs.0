Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47494 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbaJ1TGX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 15:06:23 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s9SJ6Nt8011639
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2014 15:06:23 -0400
Received: from smallhat.boston.devel.redhat.com (smallhat.boston.devel.redhat.com [10.19.60.65])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s9SJ6NnJ006301
	for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2014 15:06:23 -0400
Message-ID: <544FE92E.3080008@RedHat.com>
Date: Tue, 28 Oct 2014 15:06:22 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpcbind: exit gracefully on termination
References: <1414156386-16427-1-git-send-email-steved@redhat.com>
In-Reply-To: <1414156386-16427-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/24/2014 09:13 AM, Steve Dickson wrote:
> When systemd bring rpcbind down, via an expect signal,
> exit gracefully with a zero status and don't log a
> meaningless message.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed....

steved.

> ---
>  src/rpcbind.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index 83dbe93..1924d97 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -726,11 +726,9 @@ terminate(int dummy /*__unused*/)
>  	unlink(_PATH_RPCBINDSOCK);
>  	unlink(RPCBINDDLOCK);
>  #ifdef WARMSTART
> -	syslog(LOG_ERR,
> -		"rpcbind terminating on signal. Restart with \"rpcbind -w\"");
>  	write_warmstart();	/* Dump yourself */
>  #endif
> -	exit(2);
> +	exit(0); /* exit gracefully */
>  }
>  
>  void
> 
