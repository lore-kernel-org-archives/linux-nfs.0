From: Steve Dickson <SteveD@redhat.com>
Subject: Re: mount issue with Mac OSX and --manage-gids, client hangs
Date: Thu, 28 Aug 2008 11:08:46 -0400
Message-ID: <48B6BF7E.9090503@RedHat.com>
References: <20080731204701.GE26609@samad.com.au> <18578.41640.740866.153235@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alex Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34920 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421AbYH1POK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Aug 2008 11:14:10 -0400
In-Reply-To: <18578.41640.740866.153235-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Neil Brown wrote:
> On Friday August 1, alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org wrote:
>> I tracked it down to --manage-gids - when I remove this from
>> /etc/defaults/nfs-kernel-server everything works fine.
>>
>> Note though, the UID's, GIDs are not synced between the linux box and
>> the mac box. so the 2 users I have on the mac box uid 501 & 502, do not
>> exist on the nas box
> 
> Yes... I never tested that case, did I :-(
> 
> This patch should fix it.  Are you able to compile a new nfs-utils
> with this patch applied and test the mountd from there?
> 
> Thanks,
> NeilBrown
> 
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index f555dcc..48d737b 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -158,7 +158,8 @@ void auth_unix_gid(FILE *f)
>  		qword_printint(f, ngroups);
>  		for (i=0; i<ngroups; i++)
>  			qword_printint(f, groups[i]);
> -	}
> +	} else
> +		qword_printint(f, 0);
>  	qword_eol(f);
>  	if (groups != glist)
>  		free(groups);
Committed...

steved.
