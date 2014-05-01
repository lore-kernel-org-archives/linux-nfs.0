Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755340AbaEAPRs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2014 11:17:48 -0400
Message-ID: <53626599.7070606@RedHat.com>
Date: Thu, 01 May 2014 11:17:45 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@poochiereds.net>
CC: linux-nfs@vger.kernel.org, Jeff Law <law@redhat.com>,
        Jakub Jelinek <jakub@redhat.com>
Subject: Re: [PATCH] mountd: fix segfault in add_name with newer gcc compilers
References: <1398886759-29090-1-git-send-email-jlayton@poochiereds.net>
In-Reply-To: <1398886759-29090-1-git-send-email-jlayton@poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/30/2014 03:39 PM, Jeff Layton wrote:
> I hit a segfault in add_name with a mountd built with gcc-4.9.0. Some
> NULL pointer checks got reordered such that a pointer was dereferenced
> before checking to see whether it was NULL. The problem was due to
> nfs-utils relying on undefined behavior, which tricked gcc into assuming
> that the pointer would never be NULL.
> 
> At first I assumed that this was a compiler bug, but Jakub Jelinek and
> Jeff Law pointed out:
> 
> "If old is NULL, then:
> 
> 	strncpy(new, old, cp-old);
> 
> is undefined behavior (even when cp == old == NULL in that case),
> therefore gcc assumes that old is never NULL, as otherwise it would be
> invalid.
> 
> Just guard
> 	strncpy(new, old, cp-old);
> 	new[cp-old] = 0;
> with if (old) { ... }."
> 
> This patch does that. If old is NULL though, then we still need to
> ensure that new is NULL terminated, lest the subsequent strcats walk off
> the end of it.
> 
> Cc: Jeff Law <law@redhat.com>
> Cc: Jakub Jelinek <jakub@redhat.com>
> Signed-off-by: Jeff Layton <jlayton@poochiereds.net>
Committed...

steved.

> ---
>  support/export/client.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/support/export/client.c b/support/export/client.c
> index dbf47b966522..f85e11c8b535 100644
> --- a/support/export/client.c
> +++ b/support/export/client.c
> @@ -482,8 +482,12 @@ add_name(char *old, const char *add)
>  		else
>  			cp = cp + strlen(cp);
>  	}
> -	strncpy(new, old, cp-old);
> -	new[cp-old] = 0;
> +	if (old) {
> +		strncpy(new, old, cp-old);
> +		new[cp-old] = 0;
> +	} else {
> +		new[0] = 0;
> +	}
>  	if (cp != old && !*cp)
>  		strcat(new, ",");
>  	strcat(new, add);
> -- 1.9.0
> 
