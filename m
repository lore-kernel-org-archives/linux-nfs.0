From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] statd: Teach nfs_compare_sockaddr() to handle NULL arguments.
Date: Mon, 25 Jan 2010 13:05:58 -0500
Message-ID: <B551AB0E-5D8A-4ABD-B333-F55C8DEE3906@oracle.com>
References: <4B5DCDEB.60708@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:30195 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab0AYSGY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2010 13:06:24 -0500
In-Reply-To: <4B5DCDEB.60708-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 25, 2010, at 11:59 AM, Steve Dickson wrote:
> It seems the list of interfaces returned by getifaddrs()
> can contain a null address pointer (ifa->ifa_addr) even though
> the interface is marked UP (this happens with the tun0 interface).

It might be nice to document this quirk in from_local.c.

> So this patch makes nfs_compare_sockaddr() return false
> if either one of its arguments is null..
>
> Author: Steve Dickson <steved@redhat.com>
> Date:   Mon Jan 25 11:42:36 2010 -0500
>
>    Teach nfs_compare_sockaddr() to handle NULL arguments.
>
>    Signed-off-by: Steve Dickson <steved@redhat.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

> diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
> index 732514b..9af2543 100644
> --- a/support/include/sockaddr.h
> +++ b/support/include/sockaddr.h
> @@ -20,6 +20,7 @@
> #ifndef NFS_UTILS_SOCKADDR_H
> #define NFS_UTILS_SOCKADDR_H
>
> +#include <libio.h>
> #include <stdbool.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> @@ -223,6 +224,9 @@ compare_sockaddr6(__attribute__ ((unused)) const  
> struct sockaddr *sa1,
> static inline _Bool
> nfs_compare_sockaddr(const struct sockaddr *sa1, const struct  
> sockaddr *sa2)
> {
> +	if (sa1 == NULL || sa2 == NULL)
> +		return false;
> +
> 	if (sa1->sa_family == sa2->sa_family)
> 		switch (sa1->sa_family) {
> 		case AF_INET:
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




