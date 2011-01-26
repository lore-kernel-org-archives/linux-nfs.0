From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Fixed segfault in rpc.mountd
Date: Wed, 26 Jan 2011 11:34:37 -0500
Message-ID: <4D404D1D.6020803@RedHat.com>
References: <1296046655-20246-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752705Ab1AZQej (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jan 2011 11:34:39 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0QGYcok003994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Jan 2011 11:34:38 -0500
In-Reply-To: <1296046655-20246-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/26/2011 07:57 AM, Steve Dickson wrote:
> A unallocated piece of memory, instead of a NULL point, was being
> used to initialize a ->next point in the mount link list which
> caused a segfault after a few remote accesses via the showmount
> command.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mountd/rmtab.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
> index d339296..527377f 100644
> --- a/utils/mountd/rmtab.c
> +++ b/utils/mountd/rmtab.c
> @@ -205,6 +205,7 @@ mountlist_list(void)
>  	}
>  	if (stb.st_mtime != last_mtime) {
>  		mountlist_freeall(mlist);
> +		mlist = NULL;
>  		last_mtime = stb.st_mtime;
>  
>  		setrmtabent("r");
Committed.... 

steved.
