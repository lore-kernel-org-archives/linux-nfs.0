Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45084 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750820AbdJCSq5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Oct 2017 14:46:57 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] nfs-utils: add missing include of stdint.h
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1507055637-4928-1-git-send-email-matthew.weber@rockwellcollins.com>
Date: Tue, 3 Oct 2017 14:46:50 -0400
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5EFEA891-7F41-40F5-802E-70FD26808C5D@oracle.com>
References: <1507055637-4928-1-git-send-email-matthew.weber@rockwellcollins.com>
To: Matt Weber <matthew.weber@rockwellcollins.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 3, 2017, at 2:33 PM, Matt Weber <matthew.weber@rockwellcollins.com> wrote:
> 
> Glibc bump to 2.26 exposed this missing header when building
> with the following combination using an i386 internal toolchain.
> gcc5.4.0
> bin2.28.1
> linux4.1.43
> 
> Upstream: https://bugzilla.linux-nfs.org/show_bug.cgi?id=312
> 
> Signed-off-by: Matthew Weber <matthew.weber@rockwellcollins.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> support/nsm/rpc.c | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/support/nsm/rpc.c b/support/nsm/rpc.c
> index 4e5f40e..d91c6ea 100644
> --- a/support/nsm/rpc.c
> +++ b/support/nsm/rpc.c
> @@ -40,6 +40,7 @@
> 
> #include <time.h>
> #include <stdbool.h>
> +#include <stdint.h>
> #include <string.h>
> #include <unistd.h>
> #include <fcntl.h>
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



