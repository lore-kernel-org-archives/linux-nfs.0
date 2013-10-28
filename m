Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37876 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757333Ab3J1S2z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 14:28:55 -0400
Message-ID: <526EAD17.7080909@RedHat.com>
Date: Mon, 28 Oct 2013 14:29:43 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: NeilBrown <neilb@suse.de>, Tony Asleson <tasleson@redhat.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - nfs-utils] exportfs: report failure if asked to unexport
 something not exported.
References: <20131028144305.0f91f025@notabene.brown> <526E5CE0.5010507@RedHat.com>
In-Reply-To: <526E5CE0.5010507@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 28/10/13 08:47, Steve Dickson wrote:
> Hello,
> 
> On 27/10/13 23:43, NeilBrown wrote:
>>
>> Currently if exportfs is asked to unexport something that is not
>> exported it silently succeeds.  This is not ideal, particularly for
>> scripting situations.
>>
>> So report an error unless the unexport was successful.
>>
>> Reported-by: Tony Asleson <tasleson@redhat.com>
>> Signed-off-by: NeilBrown <neilb@suse.de>
>>
>> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
>> index 52fc03d..c9e12db 100644
>> --- a/utils/exportfs/exportfs.c
>> +++ b/utils/exportfs/exportfs.c
>> @@ -351,6 +351,7 @@ unexportfs(char *arg, int verbose)
>>  	char		*path;
>>  	char		*hname = arg;
>>  	int		htype;
>> +	int		success = 0;
>>  
>>  	if ((path = strchr(arg, ':')) != NULL)
>>  		*path++ = '\0';
>> @@ -397,7 +398,10 @@ unexportfs(char *arg, int verbose)
>>  #endif
>>  		exp->m_xtabent = 0;
>>  		exp->m_mayexport = 0;
>> +		success = 1;
>>  	}
>> +	if (!success)
>> +		xlog(L_ERROR, "Could not find %s to unexport.\n", arg);
>>  
>>  	freeaddrinfo(ai);
>>  }
>>
> This does not apply due commit 232eb7ad0... But I agree with doing a xlog
> on failures but I would like to cover it with the -v flag... Something 
> similar to :
> 
> [PATCH] exportfs: report failure if asked to unexport something not exported.
> 
> Currently if exportfs is asked to unexport something that is not
> exported it silently succeeds.  This is not ideal, particularly for
> scripting situations.
> 
> So report an error when the unexport was successful and the -v flag used.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  utils/exportfs/exportfs.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 318deb3..6962444 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -413,6 +413,8 @@ unexportfs(char *arg, int verbose)
>         exp->m_mayexport = 0;
>         rc = 1;
>     }
> +   if (!rc && verbose)
> +       xlog(L_ERROR, "Could not find '%s:%s' to unexport.", arg, path);
> 
>     freeaddrinfo(ai);
>     return rc;
> 
> 
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
