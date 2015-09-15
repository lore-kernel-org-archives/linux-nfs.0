Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49835 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807AbbIOS0y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2015 14:26:54 -0400
Subject: Re: [PATCH] Install only needed systemd unit file
To: =?UTF-8?Q?Aur=c3=a9lien_Chabot?= <aurelien@chabot.fr>,
        linux-nfs@vger.kernel.org
References: <1437428480-22951-1-git-send-email-aurelien@chabot.fr>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <55F862ED.4060900@RedHat.com>
Date: Tue, 15 Sep 2015 14:26:53 -0400
MIME-Version: 1.0
In-Reply-To: <1437428480-22951-1-git-send-email-aurelien@chabot.fr>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/20/2015 05:41 PM, Aurélien Chabot wrote:
> Signed-off-by: Aurélien Chabot <aurelien@chabot.fr>
> ---
>  systemd/Makefile.am | 22 +++++++++++++++++-----
>  1 file changed, 17 insertions(+), 5 deletions(-)
Committed.... 

Note, I also found an issue with the --with-systemd flag
which was fixed by:

commit 017164521b94018bd143b879b0e858d98cca83e8
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Sep 15 14:16:42 2015 -0400

    configure.ac: with-systemd flag not using default directory
    
    The with-systemd config flag was not using the
    default directory when a directory was not given
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

steved.

> 
> diff --git a/systemd/Makefile.am b/systemd/Makefile.am
> index fbcabb1..0331926 100644
> --- a/systemd/Makefile.am
> +++ b/systemd/Makefile.am
> @@ -5,21 +5,33 @@ MAINTAINERCLEANFILES = Makefile.in
>  unit_files =  \
>      nfs-client.target \
>      \
> -    auth-rpcgss-module.service \
> -    nfs-blkmap.service \
>      nfs-config.service \
> -    nfs-idmapd.service \
>      nfs-mountd.service \
>      nfs-server.service \
>      nfs-utils.service \
> -    rpc-gssd.service \
>      rpc-statd-notify.service \
>      rpc-statd.service \
> -    rpc-svcgssd.service \
>      \
>      proc-fs-nfsd.mount \
>      var-lib-nfs-rpc_pipefs.mount
>  
> +if CONFIG_NFSV4
> +unit_files += \
> +    nfs-idmapd.service
> +endif
> +
> +if CONFIG_NFSV41
> +unit_files += \
> +    nfs-blkmap.service
> +endif
> +
> +if CONFIG_GSS
> +unit_files += \
> +    auth-rpcgss-module.service \
> +    rpc-gssd.service \
> +    rpc-svcgssd.service
> +endif
> +
>  EXTRA_DIST = $(unit_files)
>  
>  unit_dir = /usr/lib/systemd/system
> 
