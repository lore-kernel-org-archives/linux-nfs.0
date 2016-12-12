Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38167 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750969AbcLLHfh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2016 02:35:37 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: Jia He <hejianet@gmail.com>
Cc: linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
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
        Anna Schumaker <anna.schumaker@netapp.com>, Olaf Kirch <okir@suse.de>
References: <1481527065-26109-1-git-send-email-hejianet@gmail.com>
        <1481527065-26109-3-git-send-email-hejianet@gmail.com>
Date: Mon, 12 Dec 2016 20:32:25 +1300
In-Reply-To: <1481527065-26109-3-git-send-email-hejianet@gmail.com> (Jia He's
        message of "Mon, 12 Dec 2016 15:17:45 +0800")
Message-ID: <87inqphaba.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v2 2/2] lockd: change the proc_handler for nsm_use_hostnames from int to u8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added Olaf Kirch the originator of nsm_use_hostnames to the cc.

Jia He <hejianet@gmail.com> writes:

> nsm_use_hostnames is a module paramter and it will be exported to sysctl
> procfs. This is to let user sometimes change it from userspace. But the
> minimal unit for sysctl procfs read/write it sizeof(int).
> In big endian system, the converting from/to  bool to/from int will cause
> error for proc items.
>
> This patch use a new proc_handler proc_dou8vec.
>
> Suggested-by: Pan Xinhui <xinhui@linux.vnet.ibm.com>
> Signed-off-by: Jia He <hejianet@gmail.com>
> ---
>  fs/lockd/svc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index fc4084e..7a4ad9d 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -561,7 +561,7 @@ static struct ctl_table nlm_sysctls[] = {
>  		.data		= &nsm_use_hostnames,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
> -		.proc_handler	= proc_dointvec,
> +		.proc_handler	= proc_dou8vec,

proc_dou8vec does not exist in my tree so I don't know what it does,
but if it's name is accurate this change is wrong.  As the maxlen has
not changed so you are implying that it is a vector of u8 and
sizeof(int) long.

Further this is wrong if nsm_use_hostnames is a bool as this sysctl
can be assigned values that are out of bounds for a bool.

Furthermore this is wrong in that a bool is not necessarily a u8, the
size of bool is very architecture dependent.  So for either
nsm_use_hostnames needs to become an int, a proc_dobool helper needs
to be added, or the sysctl needs to be removed entirely as module
parameters can be edited at runtime through sysfs.

But I completely agree that this decade old bug needs to be fixed.

Eric


>  	},
>  	{
>  		.procname	= "nsm_local_state",
