Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38334 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756378Ab1KNVQj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Nov 2011 16:16:39 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pAELGds8010855
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 16:16:39 -0500
Message-ID: <4EC18536.5010708@RedHat.com>
Date: Mon, 14 Nov 2011 16:16:38 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] nss_getpwnam: ignore case when comparing domain names
References: <1321111310-9481-1-git-send-email-steved@redhat.com>
In-Reply-To: <1321111310-9481-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/12/2011 10:21 AM, Steve Dickson wrote:
> nss_getpwnam() fails to find the password entry when the
> DNS domain name has both upper and lower characters,
> which is wrong. Case need to be ignored when comparing
> domain names.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  nss.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/nss.c b/nss.c
> index 04aff19..b2b1227 100644
> --- a/nss.c
> +++ b/nss.c
> @@ -141,7 +141,7 @@ static char *strip_domain(const char *name, const char *domain)
>  	if (c == NULL && domain == NULL) {
>  		len = strlen(name) + 1;
>  	} else {
> -		if (domain && strcmp(c + 1, domain) != 0)
> +		if (domain && strcasecmp(c + 1, domain) != 0)
>  			goto out;
>  		len = c - name;
>  	}
