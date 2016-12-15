Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:58858 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1757585AbcLOIMX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2016 03:12:23 -0500
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBF83vnY126320
        for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2016 03:12:22 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27bn2j0s0p-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2016 03:12:21 -0500
Received: from localhost
        by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <xinhui@linux.vnet.ibm.com>;
        Thu, 15 Dec 2016 18:12:19 +1000
Subject: Re: [PATCH v5 2/2] lockd: change the proc_handler for
 nsm_use_hostnames
To: Jia He <hejianet@gmail.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <1481786661-973-1-git-send-email-hejianet@gmail.com>
 <1481786661-973-3-git-send-email-hejianet@gmail.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Serge Hallyn <serge@hallyn.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mel Gorman <mgorman@techsingularity.net>,
        Kees Cook <keescook@chromium.org>, Hugh Dickins <hughd@google.com>,
        Daniel Bristot de Oliveira <bristot@redhat.com>,
        Daniel Cashman <dcashman@google.com>, Arnd Bergmann <arnd@arndb.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
From: Pan Xinhui <xinhui@linux.vnet.ibm.com>
Date: Thu, 15 Dec 2016 16:11:56 +0800
MIME-Version: 1.0
In-Reply-To: <1481786661-973-3-git-send-email-hejianet@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Message-Id: <cd444c70-0ebe-04df-a990-c606b9ec6ce0@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



在 2016/12/15 15:24, Jia He 写道:
> nsm_use_hostnames is a module parameter and it will be exported to sysctl
> procfs. This is to let user sometimes change it from userspace. But the
> minimal unit for sysctl procfs read/write it sizeof(int).
					^^^is^^^
> In big endian system, the converting from/to  bool to/from int will cause
> error for proc items.
>
> This patch use a new proc_handler proc_dobool to fixe it.
						 ^^^fix^^^	
> Signed-off-by: Jia He <hejianet@gmail.com>
> ---
other than that is okay for me.

Reviewed-by: Pan Xinhui <xinhui.pan@linux.vnet.ibm.com>

>  fs/lockd/svc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index fc4084e..bd6fcf9 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -561,7 +561,7 @@ static struct ctl_table nlm_sysctls[] = {
>  		.data		= &nsm_use_hostnames,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
> -		.proc_handler	= proc_dointvec,
> +		.proc_handler	= proc_dobool,
>  	},
>  	{
>  		.procname	= "nsm_local_state",
>

