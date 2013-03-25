Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757816Ab3CYOTA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 10:19:00 -0400
Message-ID: <51505CD2.3080501@RedHat.com>
Date: Mon, 25 Mar 2013 10:18:58 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH [nfs-utils]] README: drop version from file
References: <1364158618-24619-1-git-send-email-vapier@gentoo.org>
In-Reply-To: <1364158618-24619-1-git-send-email-vapier@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 24/03/13 16:56, Mike Frysinger wrote:
> It clearly doesn't get maintained, so punt it.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Committed....

steved.

> ---
>  README | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/README b/README
> index 61702f7..7034c00 100644
> --- a/README
> +++ b/README
> @@ -1,4 +1,4 @@
> -This is version 1.2.6 of nfs-utils, the Linux NFS utility package.
> +This is nfs-utils, the Linux NFS userland utility package.
>  
>  
>  0. PROJECT RESOURCES
> 
