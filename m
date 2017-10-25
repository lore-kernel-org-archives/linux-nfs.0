Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53990 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751421AbdJYTbN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Oct 2017 15:31:13 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 91D7D33A174
        for <linux-nfs@vger.kernel.org>; Wed, 25 Oct 2017 19:31:13 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-121-17.rdu2.redhat.com [10.10.121.17])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 4907F7013E
        for <linux-nfs@vger.kernel.org>; Wed, 25 Oct 2017 19:31:13 +0000 (UTC)
Subject: Re: [PATCH] sm-notify needs to call res_init() before each try
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20171012150656.5722-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <2c61c398-a350-1284-ca09-f0a273dd60f9@RedHat.com>
Date: Wed, 25 Oct 2017 15:31:12 -0400
MIME-Version: 1.0
In-Reply-To: <20171012150656.5722-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/12/2017 11:06 AM, Steve Dickson wrote:
> From: Orion Poplawski <orion@nwra.com>
> 
> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=625531
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  utils/statd/sm-notify.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
> index d216ddb..d961dc0 100644
> --- a/utils/statd/sm-notify.c
> +++ b/utils/statd/sm-notify.c
> @@ -28,6 +28,9 @@
>  #include <netdb.h>
>  #include <errno.h>
>  #include <grp.h>
> +#include <netinet/in.h>
> +#include <arpa/nameser.h>
> +#include <resolv.h>
>  
>  #include "conffile.h"
>  #include "sockaddr.h"
> @@ -90,6 +93,7 @@ smn_lookup(const char *name)
>  	};
>  	int error;
>  
> +	res_init();
>  	error = getaddrinfo(name, NULL, &hint, &ai);
>  	if (error != 0) {
>  		xlog(D_GENERAL, "getaddrinfo(3): %s", gai_strerror(error));
> 
