Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54822 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965410AbbKDVuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 16:50:24 -0500
Subject: Re: [PATCH nfs-utils] systemd/Makefile: only install
 rpc-svcgssd.service if it is required.
To: Neil Brown <nfbrown@novell.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <5606D863.9060107@RedHat.com>
 <87y4evza4c.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <563A7D9E.5010906@RedHat.com>
Date: Wed, 4 Nov 2015 16:50:22 -0500
MIME-Version: 1.0
In-Reply-To: <87y4evza4c.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/22/2015 02:32 AM, Neil Brown wrote:
> 
> If we build without rpc-svcgssd (the default), don't install matching
> .service file.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed... 

steved.

> 
> diff --git a/systemd/Makefile.am b/systemd/Makefile.am
> index 0331926dcc03..03f96e93dccf 100644
> --- a/systemd/Makefile.am
> +++ b/systemd/Makefile.am
> @@ -28,9 +28,13 @@ endif
>  if CONFIG_GSS
>  unit_files += \
>      auth-rpcgss-module.service \
> -    rpc-gssd.service \
> +    rpc-gssd.service
> +
> +if CONFIG_SVCGSS
> +unit_files += \
>      rpc-svcgssd.service
>  endif
> +endif
>  
>  EXTRA_DIST = $(unit_files)
>  
> 
