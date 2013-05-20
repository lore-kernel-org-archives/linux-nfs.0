Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f177.google.com ([209.85.217.177]:55879 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758114Ab3ETU5S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 May 2013 16:57:18 -0400
Received: by mail-lb0-f177.google.com with SMTP id o10so2753249lbi.36
        for <linux-nfs@vger.kernel.org>; Mon, 20 May 2013 13:57:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1368719808-14584-14-git-send-email-SteveD@redhat.com>
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
	<1368719808-14584-14-git-send-email-SteveD@redhat.com>
Date: Mon, 20 May 2013 16:57:16 -0400
Message-ID: <CACLa4pta+uRLDgU=hriQLVseJvtA-FJDCRK-oYKmzVNiRs299Q@mail.gmail.com>
Subject: Re: [PATCH 13/13] Kconfig: Add Kconfig entry for Labeled NFS V4 client
From: Eric Paris <eparis@parisplace.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 16, 2013 at 11:56 AM, Steve Dickson <SteveD@redhat.com> wrote:
> From: Steve Dickson <steved@redhat.com>
>
> This patch adds the NFS_V4_SECURITY_LABEL entry which
> enables security label support for the NFSv4 client
>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  fs/nfs/Kconfig | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
>
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index 79c500e..771831d3 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -107,6 +107,7 @@ config NFS_V4_1
>  config NFS_V4_2
>         bool "NFS client support for NFSv4.2"
>         depends on NFS_V4_1
> +       select NFS_V4_SECURITY_LABEL

So this will force it on...

>         help
>           This option enables support for minor version 1 of the NFSv4 protocol
>           in the kernel's NFS client.
> @@ -140,6 +141,24 @@ config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
>           If the NFS client is unchanged from the upstream kernel, this
>           option should be set to the default "kernel.org".
>
> +config NFS_V4_SECURITY_LABEL
> +       bool "Provide Security Label support for NFSv4 client"
> +       depends on NFS_V4 && SECURITY

Even if SECURITY is not set?

Why are you forcing this on with a select?  select is dangerous..

> +       help
> +
> +       Say Y here if you want enable fine-grained security label attribute
> +       support for NFS version 4.  Security labels allow security modules like
> +       SELinux and Smack to label files to facilitate enforcement of their policies.
> +       Without this an NFSv4 mount will have the same label on each file.
> +
> +       If you do not wish to enable fine-grained security labels SELinux or
> +       Smack policies on NFSv4 files, say N.
> +
> +       WARNING: there is still a chance of backwards-incompatible protocol changes.
> +       For now we recommend "Y" only for developers and testers."
> +
> +       If unsure, say N.
> +
>  config ROOT_NFS
>         bool "Root file system on NFS"
>         depends on NFS_FS=y && IP_PNP
> --
> 1.8.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
