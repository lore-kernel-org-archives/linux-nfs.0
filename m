Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46554 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751667AbdJEOzD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Oct 2017 10:55:03 -0400
Subject: Re: [PATCH] nfs-utils: add missing include of stdint.h
To: Matt Weber <matthew.weber@rockwellcollins.com>
Cc: linux-nfs@vger.kernel.org
References: <1507055637-4928-1-git-send-email-matthew.weber@rockwellcollins.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <5cf2f917-1986-4485-0383-004702715d75@RedHat.com>
Date: Thu, 5 Oct 2017 10:55:02 -0400
MIME-Version: 1.0
In-Reply-To: <1507055637-4928-1-git-send-email-matthew.weber@rockwellcollins.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/03/2017 02:33 PM, Matt Weber wrote:
> Glibc bump to 2.26 exposed this missing header when building
> with the following combination using an i386 internal toolchain.
> gcc5.4.0
> bin2.28.1
> linux4.1.43
> 
> Upstream: https://bugzilla.linux-nfs.org/show_bug.cgi?id=312
> 
> Signed-off-by: Matthew Weber <matthew.weber@rockwellcollins.com>
> ---
>  support/nsm/rpc.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/support/nsm/rpc.c b/support/nsm/rpc.c
> index 4e5f40e..d91c6ea 100644
> --- a/support/nsm/rpc.c
> +++ b/support/nsm/rpc.c
> @@ -40,6 +40,7 @@
>  
>  #include <time.h>
>  #include <stdbool.h>
> +#include <stdint.h>
>  #include <string.h>
>  #include <unistd.h>
>  #include <fcntl.h>
> 
Committed.... 

steved.
