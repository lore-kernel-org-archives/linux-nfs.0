Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31718 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753492Ab2KSPxF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Nov 2012 10:53:05 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qAJFr4ZD025301
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 19 Nov 2012 10:53:04 -0500
Message-ID: <50AA55DE.50206@RedHat.com>
Date: Mon, 19 Nov 2012 10:53:02 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] svcgssd: Encryption types not being parsed correctly
References: <1353160661-30105-1-git-send-email-steved@redhat.com>
In-Reply-To: <1353160661-30105-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 17/11/12 08:57, Steve Dickson wrote:
> When svcgssd reads the supported encrytion types from the
> kernel, they are prefixed with a 'enctypes='. That prefix
> has to be ignored to correctly parse the rest of the types.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  utils/gssd/svcgssd_krb5.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/utils/gssd/svcgssd_krb5.c b/utils/gssd/svcgssd_krb5.c
> index 6c34faf..1d44d34 100644
> --- a/utils/gssd/svcgssd_krb5.c
> +++ b/utils/gssd/svcgssd_krb5.c
> @@ -38,6 +38,7 @@
>  
>  #include <stdio.h>
>  #include <errno.h>
> +#include <ctype.h>
>  #include <gssapi/gssapi.h>
>  #include <krb5.h>
>  
> @@ -98,6 +99,12 @@ parse_enctypes(char *enctypes)
>  	if (n == 0)
>  		return ENOENT;
>  
> +	/* Skip pass any non digits */
> +	while (*enctypes && isdigit(*enctypes) == 0)
> +		enctypes++;
> +	if (*enctypes == '\0')
> +		return EINVAL;
> +
>  	/* Allocate space for enctypes array */
>  	if ((parsed_enctypes = (int *) calloc(n, sizeof(int))) == NULL) {
>  		return ENOMEM;
> 
