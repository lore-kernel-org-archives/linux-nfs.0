From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs-utils: fix endptr check in closeall
Date: Wed, 3 Jun 2009 14:32:25 -0400
Message-ID: <F8220E4B-E995-4751-9913-AA5C023650D0@oracle.com>
References: <1244045242-8853-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17449 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbZFCSdt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2009 14:33:49 -0400
In-Reply-To: <1244045242-8853-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 3, 2009, at 12:07 PM, Jeff Layton wrote:

> The closeall function is broken in such a way that it almost never
> closes any file descriptors. It's calling strtol on the text
> representation of the file descriptor, and then checking to see if the
> value of *endptr is not '\0' before trying to close the file. This  
> check
> is wrong.
>
> When strtol returns an endptr that points to a NULL byte, that  
> indicates
> that the conversion was completely successful.

In this case, that is true.  In general, endptr points to the first  
non-numeric byte in the input string.  Since we are dealing with a  
string that should be nothing more than a single integer, we know we  
got the whole string if endptr is pointing to '\0' after the  
conversion.  However, this doesn't detect the (possibly rare) case  
where "" is the input string, for example.

> I believe this check
> should instead be requiring that endptr is pointing to '\0' before  
> closing
> the fd.

When I use the strto* functions, I usually set errno to zero before  
calling, then check if it's still zero afterwards.  And, if endptr  
points to the first byte in the string, that means there were no  
numerics in the input to convert.

Just a thought.  It really depends on how forgiving we want this code  
to be.  Personally, I think this function might be just a bit too  
clever for its own good.

> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> support/nfs/closeall.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/support/nfs/closeall.c b/support/nfs/closeall.c
> index cc7fb3b..4c93882 100644
> --- a/support/nfs/closeall.c
> +++ b/support/nfs/closeall.c
> @@ -19,7 +19,7 @@ closeall(int min)
> 		while ((d = readdir(dir)) != NULL) {
> 			char *endp;
> 			long n = strtol(d->d_name, &endp, 10);
> -			if (*endp != '\0' && n >= min && n != dfd)
> +			if (*endp == '\0' && n >= min && n != dfd)
> 				(void) close(n);
> 		}
> 		closedir(dir);
> -- 
> 1.6.2.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



