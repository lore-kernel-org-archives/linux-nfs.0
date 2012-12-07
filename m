Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40931 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030214Ab2LGNEV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 08:04:21 -0500
Date: Fri, 7 Dec 2012 08:04:18 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Abhijit Pawar <abhi.c.pawar@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] include/sunrpc: remove obsolete simple_strto<foo>
Message-ID: <20121207130418.GC17115@fieldses.org>
References: <1354881096-23480-1-git-send-email-abhi.c.pawar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1354881096-23480-1-git-send-email-abhi.c.pawar@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 07, 2012 at 05:21:36PM +0530, Abhijit Pawar wrote:
> This patch replace the obsolete simple_strto<foo> with kstrto<foo>

No, we can't apply this as is--see the recent revert of a similar
change, below.

kstrtoint does not have the same behavior as simple_strtol, so don't
blindly replace one by the other.  At a bare minimum the changelog
should have a note about the differences to help maintainers determine
if the change will cause problems.

--b.

> Signed-off-by: Abhijit Pawar <abhi.c.pawar@gmail.com>
> ---
>  include/linux/sunrpc/cache.h |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index 5dc9ee4..96d2545 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -218,7 +218,7 @@ static inline int get_int(char **bpp, int *anint)
>  {
>  	char buf[50];
>  	char *ep;
> -	int rv;
> +	int rv, rc;
>  	int len = qword_get(bpp, buf, sizeof(buf));
>  
>  	if (len < 0)
> @@ -226,8 +226,8 @@ static inline int get_int(char **bpp, int *anint)
>  	if (len == 0)
>  		return -ENOENT;
>  
> -	rv = simple_strtol(buf, &ep, 0);
> -	if (*ep)
> +	rc = kstrtoint(buf, 0, &rv);
> +	if (rc)
>  		return -EINVAL;
>  
>  	*anint = rv;

commit 621eb19ce1ec216e03ad354cb0c4061736b2a436
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Nov 14 10:48:05 2012 -0500

    svcrpc: Revert "sunrpc/cache.h: replace simple_strtoul"
    
    Commit bbf43dc888833ac0539e437dbaeb28bfd4fbab9f "sunrpc/cache.h: replace
    simple_strtoul" introduced new range-checking which could cause get_int
    to fail on unsigned integers too large to be represented as an int.
    
    We could parse them as unsigned instead--but it turns out svcgssd is
    actually passing down "-1" in some cases.  Which is perhaps stupid, but
    there's nothing we can do about it now.
    
    So just revert back to the previous "sloppy" behavior that accepts
    either representation.
    
    Cc: stable@vger.kernel.org
    Reported-by: Sven Geggus <lists@fuchsschwanzdomain.de>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index f792794..5dc9ee4 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -217,6 +217,8 @@ extern int qword_get(char **bpp, char *dest, int bufsize);
 static inline int get_int(char **bpp, int *anint)
 {
 	char buf[50];
+	char *ep;
+	int rv;
 	int len = qword_get(bpp, buf, sizeof(buf));
 
 	if (len < 0)
@@ -224,9 +226,11 @@ static inline int get_int(char **bpp, int *anint)
 	if (len == 0)
 		return -ENOENT;
 
-	if (kstrtoint(buf, 0, anint))
+	rv = simple_strtol(buf, &ep, 0);
+	if (*ep)
 		return -EINVAL;
 
+	*anint = rv;
 	return 0;
 }
 
