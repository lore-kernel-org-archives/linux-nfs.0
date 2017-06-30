Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41672 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751668AbdF3Okw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 10:40:52 -0400
Subject: Re: [PATCH nfs-utils v2 03/12] mount: present AF_VSOCK addresses
To: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-4-stefanha@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <dc1bd4ee-621f-d988-2914-61b1c144f146@RedHat.com>
Date: Fri, 30 Jun 2017 10:40:49 -0400
MIME-Version: 1.0
In-Reply-To: <20170630132120.31578-4-stefanha@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> Format vsock hosts as "vsock:<cid>" so the addresses can be easily
> distinguished from IPv4 and IPv6 addresses.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
>  utils/mount/network.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 281e935..b5dcaa5 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -45,6 +45,8 @@
>  #include <rpc/pmap_prot.h>
>  #include <rpc/pmap_clnt.h>
>  
> +#include <linux/vm_sockets.h>
In the previous patch you had this surrounded by #ifdef AF_VSOCK
I'm not keen on sprinkling a bunch ifdefs around since 
I think it makes the code harder to read. So my question 
is why is the ifdef need in the previous patch and
not needed in this patch and are they needed in the
previous patch?

steved.

> +
>  #include "sockaddr.h"
>  #include "xcommon.h"
>  #include "mount.h"
> @@ -325,6 +327,12 @@ int nfs_string_to_sockaddr(const char *address, struct sockaddr *sap,
>  int nfs_present_sockaddr(const struct sockaddr *sap, const socklen_t salen,
>  			 char *buf, const size_t buflen)
>  {
> +	if (sap->sa_family == AF_VSOCK) {
> +		snprintf(buf, buflen, "vsock:%u",
> +			 ((struct sockaddr_vm *)sap)->svm_cid);
> +		return 1;
> +	}
> +
>  #ifdef HAVE_GETNAMEINFO
>  	int result;
>  
> 
