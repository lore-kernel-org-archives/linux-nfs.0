Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53258 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757820AbcHYLpa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Aug 2016 07:45:30 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F2FDD3407F6
        for <linux-nfs@vger.kernel.org>; Thu, 25 Aug 2016 11:45:29 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-58-14.rdu2.redhat.com [10.10.58.14])
        by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u7PBjTjQ001047
        for <linux-nfs@vger.kernel.org>; Thu, 25 Aug 2016 07:45:29 -0400
Subject: Re: [PATCH] rpc-gssd: Make the path to the keytab configurable.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1472066095-15650-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <22dde429-8352-b734-d761-d71a50423af8@RedHat.com>
Date: Thu, 25 Aug 2016 07:45:29 -0400
MIME-Version: 1.0
In-Reply-To: <1472066095-15650-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/24/2016 03:14 PM, Steve Dickson wrote:
> Kerberos keytabs don't always live in the '/etc'
> directory. Allow --sysconfdir flag to define where
> the keytab directory is in rpc-gssd.service
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed.... 

steved.
> ---
>  .gitignore                  |  1 +
>  configure.ac                |  6 ++++++
>  systemd/rpc-gssd.service    | 19 -------------------
>  systemd/rpc-gssd.service.in | 19 +++++++++++++++++++
>  4 files changed, 26 insertions(+), 19 deletions(-)
>  delete mode 100644 systemd/rpc-gssd.service
>  create mode 100644 systemd/rpc-gssd.service.in
> 
> diff --git a/.gitignore b/.gitignore
> index c247561..126d12c 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -71,6 +71,7 @@ tests/nsm_client/nlm_sm_inter_xdr.c
>  utils/nfsidmap/nfsidmap
>  systemd/nfs-server-generator
>  systemd/nfs-config.service
> +systemd/rpc-gssd.service
>  # cscope database files
>  cscope.*
>  # generic editor backup et al
> diff --git a/configure.ac b/configure.ac
> index 4fb108f..d60f3a2 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -516,9 +516,15 @@ AC_SUBST([ACLOCAL_AMFLAGS], ["-I $ac_macro_dir \$(ACLOCAL_FLAGS)"])
>  AC_SUBST([_libexecdir])
>  AC_CONFIG_COMMANDS_PRE([eval eval _libexecdir=$libexecdir])
>  
> +# make _sysconfdir available for substituion in config files
> +# 2 "evals" needed late to expand variable names.
> +AC_SUBST([_sysconfdir])
> +AC_CONFIG_COMMANDS_PRE([eval eval _sysconfdir=$sysconfdir])
> +
>  AC_CONFIG_FILES([
>  	Makefile
>  	systemd/nfs-config.service
> +	systemd/rpc-gssd.service
>  	linux-nfs/Makefile
>  	support/Makefile
>  	support/export/Makefile
> diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
> deleted file mode 100644
> index d4a3819..0000000
> --- a/systemd/rpc-gssd.service
> +++ /dev/null
> @@ -1,19 +0,0 @@
> -[Unit]
> -Description=RPC security service for NFS client and server
> -DefaultDependencies=no
> -Conflicts=umount.target
> -Requires=var-lib-nfs-rpc_pipefs.mount
> -After=var-lib-nfs-rpc_pipefs.mount
> -
> -ConditionPathExists=/etc/krb5.keytab
> -
> -PartOf=nfs-utils.service
> -
> -Wants=nfs-config.service
> -After=nfs-config.service
> -
> -[Service]
> -EnvironmentFile=-/run/sysconfig/nfs-utils
> -
> -Type=forking
> -ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
> diff --git a/systemd/rpc-gssd.service.in b/systemd/rpc-gssd.service.in
> new file mode 100644
> index 0000000..1a7911c
> --- /dev/null
> +++ b/systemd/rpc-gssd.service.in
> @@ -0,0 +1,19 @@
> +[Unit]
> +Description=RPC security service for NFS client and server
> +DefaultDependencies=no
> +Conflicts=umount.target
> +Requires=var-lib-nfs-rpc_pipefs.mount
> +After=var-lib-nfs-rpc_pipefs.mount
> +
> +ConditionPathExists=@_sysconfdir@/krb5.keytab
> +
> +PartOf=nfs-utils.service
> +
> +Wants=nfs-config.service
> +After=nfs-config.service
> +
> +[Service]
> +EnvironmentFile=-/run/sysconfig/nfs-utils
> +
> +Type=forking
> +ExecStart=/usr/sbin/rpc.gssd $GSSDARGS
> 
