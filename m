Return-Path: linux-nfs-owner@vger.kernel.org
Received: from perches-mx.perches.com ([206.117.179.246]:52822 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754236Ab2GDXXs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jul 2012 19:23:48 -0400
Message-ID: <1341444227.2058.5.camel@joe2Laptop>
Subject: Re: [PATCH 2/2] sunrpc/cache.h: replace simple_strtoul
From: Joe Perches <joe@perches.com>
To: Eldad Zack <eldad@fogrefinery.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 04 Jul 2012 16:23:47 -0700
In-Reply-To: <1341442827-21339-2-git-send-email-eldad@fogrefinery.com>
References: <1341442827-21339-1-git-send-email-eldad@fogrefinery.com>
	 <1341442827-21339-2-git-send-email-eldad@fogrefinery.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-07-05 at 01:00 +0200, Eldad Zack wrote:
> This patch replaces the usage of simple_strtoul with kstrtoint in
> get_int().

Just some trivia:

> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
[]
> @@ -217,7 +217,7 @@ extern int qword_get(char **bpp, char *dest, int bufsize);
>  static inline int get_int(char **bpp, int *anint)
>  {
>  	char buf[50];
> -	char *ep;
> +	ssize_t ret;
>  	int rv;
>  	int len = qword_get(bpp, buf, 50);

This would be nicer as
	int len = qword_get(bpp, buf, sizeof(buf));

> @@ -226,8 +226,8 @@ static inline int get_int(char **bpp, int *anint)
>  	if (len == 0)
>  		return -ENOENT;
>  
> -	rv = simple_strtol(buf, &ep, 0);
> -	if (*ep)
> +	ret = kstrtoint(buf, 0, &rv);
> +	if (ret)
>  		return -EINVAL;
>  
>  	*anint = rv;

ret and rv aren't useful anymore.

Perhaps:

	if (kstrtoint(buf, 0, anint))
		return -EINVAL;

	return 0;


