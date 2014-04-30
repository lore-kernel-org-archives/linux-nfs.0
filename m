Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:57035 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945957AbaD3QaS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2014 12:30:18 -0400
Received: by mail-qa0-f48.google.com with SMTP id j15so1864663qaq.7
        for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2014 09:30:17 -0700 (PDT)
Date: Wed, 30 Apr 2014 12:30:13 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] libnfsidmap: id_as_chars() fails zero value ids.
Message-ID: <20140430123013.4c4cc8ec@tlielax.poochiereds.net>
In-Reply-To: <1398871108-18213-1-git-send-email-steved@redhat.com>
References: <1398871108-18213-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 30 Apr 2014 11:18:28 -0400
Steve Dickson <steved@redhat.com> wrote:

> Root has a zero value id which is valid and
> should not be mapped to nfsnobody
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  libnfsidmap.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/libnfsidmap.c b/libnfsidmap.c
> index 641d766..92bc493 100644
> --- a/libnfsidmap.c
> +++ b/libnfsidmap.c
> @@ -99,8 +99,12 @@ static char * toupper_str(char *s)
>  static int id_as_chars(char *name, int *id)
>  {
>  	long int value = strtol(name, NULL, 10);
> -	if (value == 0)
> -		return 0;
> +
> +	if (value == 0) {
> +		/* zero value ids are valid */
> +		if (strcmp(name, "0") != 0)
> +			return 0;
> +	}
>  	*id = (int)value;
>  	return 1;
>  }

Well spotted. I think though that instead of doing the strcmp, you
should instead just use the endptr value in the strtol call to determine
whether the string was completely converted. If it isn't, we can just
return 0 here. If it is completely converted then you know that you got
a legit "0" string.

-- 
Jeff Layton <jlayton@poochiereds.net>
