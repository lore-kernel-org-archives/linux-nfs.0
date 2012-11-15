Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:54940 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768414Ab2KOQ6a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Nov 2012 11:58:30 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<lists@fuchsschwanzdomain.de>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1TZ2lp-0000Aa-1w
	for linux-nfs@vger.kernel.org; Thu, 15 Nov 2012 17:58:29 +0100
Date: Thu, 15 Nov 2012 17:58:24 +0100
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Eldad Zack <eldad@fogrefinery.com>
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121115165823.GA5505@geggus.net>
References: <20121109200730.GI6171@fieldses.org>
 <E1TWxKX-00025I-J2@diesel.geggus.net>
 <20121109232410.GK6171@fieldses.org>
 <20121112091717.GA1610@geggus.net>
 <20121113224005.GA11545@fieldses.org>
 <20121114005815.GA23604@fieldses.org>
 <20121114160712.GG23604@fieldses.org>
 <20121114160808.GH23604@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20121114160808.GH23604@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields schrieb am Mittwoch, den 14. November um 17:08 Uhr:

> commit 8688bcb10bd006111b1b46c23a27081ea359e140
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Wed Nov 14 10:48:05 2012 -0500
> 
>     svcrpc: Revert "sunrpc/cache.h: replace simple_strtoul"
>     
>     Commit bbf43dc888833ac0539e437dbaeb28bfd4fbab9f "sunrpc/cache.h: replace
>     simple_strtoul" introduced new range-checking which could cause get_int
>     to fail on unsigned integers to large to be represented as an int.
>     
>     We could parse them as unsigned instead--but it turns out svcgssd is
>     actually passing down "-1" in some cases.  Which is perhaps stupid, but
>     there's nothing we can do about it now.
>     
>     So just revert back to the previous "sloppy" behavior that accepts
>     either representation.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index f792794..5dc9ee4 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -217,6 +217,8 @@ extern int qword_get(char **bpp, char *dest, int bufsize);
>  static inline int get_int(char **bpp, int *anint)
>  {
>  	char buf[50];
> +	char *ep;
> +	int rv;
>  	int len = qword_get(bpp, buf, sizeof(buf));
>  
>  	if (len < 0)
> @@ -224,9 +226,11 @@ static inline int get_int(char **bpp, int *anint)
>  	if (len == 0)
>  		return -ENOENT;
>  
> -	if (kstrtoint(buf, 0, anint))
> +	rv = simple_strtol(buf, &ep, 0);
> +	if (*ep)
>  		return -EINVAL;
>  
> +	*anint = rv;
>  	return 0;
>  }

OK, so this can be marked as resolved (for now) on my todo list, right? Will
this go into 3.6.7 and of course 3.7?

Sven

-- 
"Those who do not understand Unix are condemned to reinvent it, poorly"
(Henry Spencer)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
