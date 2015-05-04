Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752301AbbEDLfW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 May 2015 07:35:22 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 6CDA78E6FC
	for <linux-nfs@vger.kernel.org>; Mon,  4 May 2015 11:35:22 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-59-87.rdu2.redhat.com [10.10.59.87])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t44BZLLb028659
	for <linux-nfs@vger.kernel.org>; Mon, 4 May 2015 07:35:21 -0400
Message-ID: <55475978.4060809@RedHat.com>
Date: Mon, 04 May 2015 07:35:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Handle NULL names better
References: <1430417344-25020-1-git-send-email-steved@redhat.com>
In-Reply-To: <1430417344-25020-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/30/2015 02:09 PM, Steve Dickson wrote:
> Detect when an application passes in NULL names
> and fail gracefully instead of crashing hard.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.
> ---
>  libnfsidmap.c | 5 ++++-
>  nss.c         | 3 +++
>  2 files changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/libnfsidmap.c b/libnfsidmap.c
> index 833f94c..a8a9229 100644
> --- a/libnfsidmap.c
> +++ b/libnfsidmap.c
> @@ -100,8 +100,11 @@ static char * toupper_str(char *s)
>  
>  static int id_as_chars(char *name, uid_t *id)
>  {
> -	long int value = strtol(name, NULL, 10);
> +	long int value;
>  
> +	if (name == NULL)
> +		return 0;
> +	value = strtol(name, NULL, 10);
>  	if (value == 0) {
>  		/* zero value ids are valid */
>  		if (strcmp(name, "0") != 0)
> diff --git a/nss.c b/nss.c
> index f8129fe..b3fef5a 100644
> --- a/nss.c
> +++ b/nss.c
> @@ -135,6 +135,9 @@ static char *strip_domain(const char *name, const char *domain)
>  	char *l = NULL;
>  	int len;
>  
> +	if (name == NULL)
> +		goto out;
> +
>  	c = strrchr(name, '@');
>  	if (c == NULL && domain != NULL)
>  		goto out;
> 
