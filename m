From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] nfs-utils: Enabling TCP wrappers
Date: Thu, 18 Dec 2008 15:23:55 -0500
Message-ID: <04AA0955-045D-432B-B96D-4A21F4889F6D@oracle.com>
References: <49468BC7.2000907@RedHat.com> <1819C671-5353-45B4-A814-98B1B2A4BEB1@oracle.com> <494AABA1.4070006@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>, Olaf Kirch <okir@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:64451 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbYLRUZX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Dec 2008 15:25:23 -0500
In-Reply-To: <494AABA1.4070006-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 18, 2008, at Dec 18, 2008, 2:59 PM, Steve Dickson wrote:
> Chuck Lever wrote:
>>
>> A general comment:  This code will need support for IPv6 addresses.
>>
>> Until it has it, perhaps we should add some logic to configure.ac  
>> that
>> prevents the use of tcpwrappers when --enable-ipv6 is in effect.
> The following patch does address this concern....
>
> comments?
>
> steved.
>
>
> commit 5526bb225c745d169c070d392402fc1a569f1d15
> Author: Steve Dickson <steved@redhat.com>
> Date:   Thu Dec 18 14:57:52 2008 -0500
>
>    Skip the host access check when IPv6 is enabled and its an IPv6  
> address.
>
>    Signed-off-by: Steve Dickson <steved@redhat.com>
>
> diff --git a/utils/mountd/mount_dispatch.c b/utils/mountd/ 
> mount_dispatch.c
> index f00c0c5..8aa1955 100644
> --- a/utils/mountd/mount_dispatch.c
> +++ b/utils/mountd/mount_dispatch.c
> @@ -12,6 +12,8 @@
> #include "tcpwrapper.h"
> #endif
>
> +#include <sys/syslog.h>
> +
> #include "mountd.h"
> #include "rpcmisc.h"
>
> @@ -72,12 +74,29 @@ mount_dispatch(struct svc_req *rqstp, SVCXPRT  
> *transp)
> 	union mountd_results	result;
>
> #ifdef HAVE_TCP_WRAPPER
> +#ifdef IPV6_SUPPORTED
> +	static int once = 0;
> +
> +	if (svc_getcaller(transp)->sin_family != AF_INET) {

It's not clear to me that svc_getcaller() will ever return a non- 
AF_INET address.

Should we use svc_getcaller_netbuf() here instead?

>
> +		if (!once) {
> +			syslog(LOG_WARNING,
> +				"No IPv6 support in Access Control Library (TCP Wrappers)");
> +			once++;
> +		}
> +		goto skipcheck;
> +	}
> +#endif
> 	/* remote host authorization check */
> 	if (!check_default("mountd", svc_getcaller(transp),
> 			   rqstp->rq_proc, MOUNTPROG)) {
> 		svcerr_auth (transp, AUTH_FAILED);
> 		return;
> 	}
> +
> +#ifdef IPV6_SUPPORTED
> +skipcheck:
> +#endif
> +
> #endif
>
> 	rpc_dispatch(rqstp, transp, dtable, number_of(dtable),

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




