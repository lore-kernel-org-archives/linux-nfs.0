Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57494 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757816Ab3CYOSQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 10:18:16 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r2PEIGBc029626
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 25 Mar 2013 10:18:16 -0400
Message-ID: <51505CA6.7050306@RedHat.com>
Date: Mon, 25 Mar 2013 10:18:14 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountd: regression in crossmounts
References: <1364049149-3751-1-git-send-email-steved@redhat.com>
In-Reply-To: <1364049149-3751-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 23/03/13 10:32, Steve Dickson wrote:
> commit 8e2fb3fc cause a regression in mount export
> that are on different local file system.
> Exports like (all on different filesystems)
> 
> /home *(rw,fsid=0,crossmnt)
> /home/fs1 *(rw,crossmnt)
> /home/fs1/fs2/fs3 *(rw,nohide)
> 
> and then a mount of the root 'mount /home /mnt'
> would end up mounting /home/fs1/fs2/fs3 not /home
> 
> Reverting the logic of commit 8e2fb3fc until
> a better solution can be found for the original
> problem.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  utils/mountd/cache.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index c8aa46f..978698d 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -371,8 +371,11 @@ export_matches(nfs_export *exp, char *dom, char *path, struct addrinfo *ai)
>  static bool subexport(struct exportent *e1, struct exportent *e2)
>  {
>  	char *p1 = e1->e_path, *p2 = e2->e_path;
> +	size_t l2 = strlen(p2);
> +
>  	return e2->e_flags & NFSEXP_CROSSMOUNT
> -		&& is_subdirectory(p1, p2);
> +		&& strncmp(p1, p2, l2) == 0
> +		&& p1[l2] == '/';
>  }
>  
>  struct parsed_fsid {
> 
