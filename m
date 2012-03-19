Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46554 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161913Ab2CST5z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 15:57:55 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q2JJvsnP024318
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 19 Mar 2012 15:57:54 -0400
Message-ID: <4F678FBE.8010206@RedHat.com>
Date: Mon, 19 Mar 2012 15:57:50 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] Makefile.am: install target in doc/Makefile.am doesn't
 honor sysconfdir
References: <1332161508-20391-1-git-send-email-steved@redhat.com>
In-Reply-To: <1332161508-20391-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/19/2012 08:51 AM, Steve Dickson wrote:
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  doc/Makefile.am |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/doc/Makefile.am b/doc/Makefile.am
> index cc4fa76..f8c88b5 100644
> --- a/doc/Makefile.am
> +++ b/doc/Makefile.am
> @@ -1,5 +1,5 @@
>  
>  install: install-am
> -	$(mkinstalldirs) $(DESTDIR)/etc
> -	cp -p ./etc_netconfig $(DESTDIR)/etc/netconfig
> -	chmod 0644 $(DESTDIR)/etc/netconfig
> +	$(mkinstalldirs) $(DESTDIR)/$(sysconfdir)
> +	cp -p ./etc_netconfig $(DESTDIR)/$(sysconfdir)/netconfig
> +	chmod 0644 $(DESTDIR)/$(sysconfdir)/netconfig
Committed...

steved.
