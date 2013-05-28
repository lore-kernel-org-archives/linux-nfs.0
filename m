Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750802Ab3E1SnG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 May 2013 14:43:06 -0400
Message-ID: <51A4FAB7.5040901@RedHat.com>
Date: Tue, 28 May 2013 14:43:03 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Luk Claes <luk@debian.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsidmap: add default id_resolver.conf
References: <1368468223-21982-1-git-send-email-luk@debian.org>
In-Reply-To: <1368468223-21982-1-git-send-email-luk@debian.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 13/05/13 14:03, Luk Claes wrote:
> Ship default id_resolver.conf to put into /etc/request-key.d so
> it is impossible to forget to add the file while upgrading.
Committed even though there was no Signed-off-by line... :-( 

steved.


> ---
>  utils/nfsidmap/id_resolver.conf |    1 +
>  1 file changed, 1 insertion(+)
>  create mode 100644 utils/nfsidmap/id_resolver.conf
> 
> diff --git a/utils/nfsidmap/id_resolver.conf b/utils/nfsidmap/id_resolver.conf
> new file mode 100644
> index 0000000..2c156c6
> --- /dev/null
> +++ b/utils/nfsidmap/id_resolver.conf
> @@ -0,0 +1 @@
> +create	id_resolver	*	*	/usr/sbin/nfsidmap -t 600 %k %d
> 
