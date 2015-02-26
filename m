Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36295 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844AbbBZTgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Feb 2015 14:36:47 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1QJalBM012576
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 14:36:47 -0500
Message-ID: <54EF75CD.2030805@RedHat.com>
Date: Thu, 26 Feb 2015 14:36:45 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Carlos O'Donell" <carlos@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.statd: Avoid passing unregistered socket to svc_getreqset.
References: <54E60C41.3060001@redhat.com>
In-Reply-To: <54E60C41.3060001@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/19/2015 11:16 AM, Carlos O'Donell wrote:
> rpc.statd may crash if it receives both a notification reply and a client
> connection at the same time. It crashes because it adds sockfd to SVC_FDSET
> and that violates the API contract. The SVC_FDSET is to be considered read-only
> and must not be modified by user code. The daemon modifies it for expediency
> to avoid having to maintain two distinct fd lists and select on each one.
> It is a practical choice that makes sense.
> 
> Thus, if a notification reply arrives by itself everything works, or if a
> client connection arrives by itself everything works. Both must arrive at
> the same time for sockfd to be set in SVC_FDSET and to be processed by
> svc_getreqset because more than one of readfds is ready.
> 
> It is the processing by svc_getreqset that will crash when it finds an
> unregistered fd in the list that doesn't correlate to any of the internal
> book keeping done by the library. At present the glibc SunRPC library will
> crash, but TIRPC does not (it is robust against invalid API usage in this
> case). However, future RPC libraries may be implemented differently, and
> the questionable API usage should be fixed.
> 
> The simplest fix is for process_reply to *clear* sockfd from the
> ready-to-read fds, since it was never registered with xprt_register.
> This works because the code always calls process_reply before handing the 
> fd set to the RPC layer for processing.
> 
> Compile-tested on x86_64 against master.
> 
> Signed-off-by: Carlos O'Donell <carlos@redhat.com>
Committed!

steved.

> ---
>  rmtcall.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
> index fd576d9..66a6eeb 100644
> --- a/utils/statd/rmtcall.c
> +++ b/utils/statd/rmtcall.c
> @@ -221,6 +221,9 @@ process_reply(FD_SET_TYPE *rfds)
>  	if (sockfd == -1 || !FD_ISSET(sockfd, rfds))
>  		return 0;
>  
> +	/* Should not be processed again. */
> +	FD_CLR (sockfd, rfds);
> +
>  	if (!(lp = recv_rply(&port)))
>  		return 1;
>  
> 
