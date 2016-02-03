Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194AbcBCQap (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2016 11:30:45 -0500
Subject: Re: [Linux-cachefs] [PATCH 2/2] Suspend/resume culling based on
 recently released file/block counts
To: David Howells <dhowells@redhat.com>
References: <56AFEA5E.2080401@redhat.com>
 <20160125164111.9466.79976.stgit@warthog.procyon.org.uk>
 <20160125164937.9670.4281.stgit@warthog.procyon.org.uk>
 <20004.1454508072@warthog.procyon.org.uk>
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, neilb@suse.de,
        linux-fsdevel@vger.kernel.org, jlayton@poochiereds.net
From: John Snow <jsnow@redhat.com>
Message-ID: <56B22B34.2000306@redhat.com>
Date: Wed, 3 Feb 2016 11:30:44 -0500
MIME-Version: 1.0
In-Reply-To: <20004.1454508072@warthog.procyon.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/03/2016 09:01 AM, David Howells wrote:
> John Snow <jsnow@redhat.com> wrote:
> 
>>> +			if (!*sp || !isspace(*sp) || b_thresh == 0)
>>> +				cfgerror("Invalid resume threshold (blocks)");
>>
>> Seems to me like we're mixing parsing errors with invalid configuration
>> error messages, but I'm just bike-shedding aboard the SS Howells.
> 
> How about this further modification?
> 
> -			if (!*sp || !isspace(*sp) || b_thresh == 0)
> +			if (!*sp || !isspace(*sp))
> +				cfgerror("Error parsing resume threshold (blocks)");
> +			if (b_thresh == 0)
>  				cfgerror("Invalid resume threshold (blocks)");
>  			for (; isspace(*sp); sp++) {;}
>  
> @@ -470,7 +472,9 @@ int main(int argc, char *argv[])
>  				f_thresh = ULLONG_MAX;
>  			} else {
>  				f_thresh = strtoul(sp, &sp, 10);
> -				if (*sp || f_thresh == 0)
> +				if (*sp)
> +					cfgerror("Error parsing resume threshold (files)");
> +				if (f_thresh == 0)
>  					cfgerror("Invalid resume threshold (files)");
> 
> David
> 

I'm fine with either; I gave my R-B regardless. I'm fine with this
change, too.
