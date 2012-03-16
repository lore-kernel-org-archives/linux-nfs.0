Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760859Ab2CPN4D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Mar 2012 09:56:03 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q2GDu2Ur018837
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 09:56:03 -0400
Message-ID: <4F63466E.3020603@RedHat.com>
Date: Fri, 16 Mar 2012 09:55:58 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] rpc.idmap: Hide global symbols from libidmap plugins
References: <1331830642-18908-1-git-send-email-steved@redhat.com>
In-Reply-To: <1331830642-18908-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/15/2012 12:57 PM, Steve Dickson wrote:
> From: Noah Friedman <friedman@splode.com>
> 
> This patch limits the visibility of the symbols in the nfs-utils
> conffile.c so that they are only visible to programs linked directly to
> it.  This forces the objects dynamically loaded via libnfsidmap to use
> the functions defined in that shared library instead.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  support/nfs/conffile.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index 2f1e235..5015e94 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -49,6 +49,8 @@
>  #include "conffile.h"
>  #include "xlog.h"
>  
> +#pragma GCC visibility push(hidden)
> +
>  static void conf_load_defaults(void);
>  static int conf_set(int , char *, char *, char *, 
>  	char *, int , int );
