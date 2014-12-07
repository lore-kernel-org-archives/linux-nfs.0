Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752980AbaLGPmg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Dec 2014 10:42:36 -0500
Message-ID: <54847568.10401@RedHat.com>
Date: Sun, 07 Dec 2014 10:42:32 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [nfs-utils PATCH 2/2] Include systemd unit files in "dist" and
 "install".
References: <20141105140522.5cffda9e@notabene.brown>
In-Reply-To: <20141105140522.5cffda9e@notabene.brown>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/04/2014 10:05 PM, NeilBrown wrote:
> 
> New configure option "--with-systemd" will causes systemd
> unit files to be installed in /usr/lib/systemd/system.
> Alternalte a path can be given:
>     --with-systemd=/lib/systemd/system
> 
> Also, systemd files get included in "make dist" now.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed... Thanks!

steved.
> ---
>  Makefile.am         |  2 +-
>  configure.ac        | 11 +++++++++++
>  systemd/Makefile.am | 32 ++++++++++++++++++++++++++++++++
>  3 files changed, 44 insertions(+), 1 deletion(-)
>  create mode 100644 systemd/Makefile.am
> 
> diff --git a/Makefile.am b/Makefile.am
> index 392e7b364359..4a2edc682de8 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -2,7 +2,7 @@
>  
>  AUTOMAKE_OPTIONS = foreign
>  
> -SUBDIRS = tools support utils linux-nfs tests
> +SUBDIRS = tools support utils linux-nfs tests systemd
>  
>  MAINTAINERCLEANFILES = Makefile.in
>  
> diff --git a/configure.ac b/configure.ac
> index 59fd14d253ff..db1c261c8ce1 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -55,6 +55,16 @@ AC_ARG_WITH(start-statd,
>  	)
>  	AC_SUBST(startstatd)
>  	AC_DEFINE_UNQUOTED(START_STATD, "$startstatd", [Define this to a script which can start statd on mount])
> +unitdir=/usr/lib/systemd/system
> +AC_ARG_WITH(systemd,
> +	[AC_HELP_STRING([--with-systemd@<:@=unit-dir-path@:>@],
> +			[install systemd unit files @<:@Default: no, and path defaults to /usr/lib/systemd/system if not given@:>@])],
> +	test "$withval" = "no" && use_systemd=0 || unitdir=$withval use_systemd=1
> +	use_systemd=0
> +	)
> +	AM_CONDITIONAL(INSTALL_SYSTEMD, [test "$use_systemd" = 1])
> +	AC_SUBST(unitdir)
> +
>  AC_ARG_ENABLE(nfsv4,
>  	[AC_HELP_STRING([--enable-nfsv4],
>                          [enable support for NFSv4 @<:@default=yes@:>@])],
> @@ -518,6 +528,7 @@ AC_CONFIG_FILES([
>  	utils/showmount/Makefile
>  	utils/statd/Makefile
>  	utils/osd_login/Makefile
> +	systemd/Makefile
>  	tests/Makefile
>  	tests/nsm_client/Makefile])
>  AC_OUTPUT
> diff --git a/systemd/Makefile.am b/systemd/Makefile.am
> new file mode 100644
> index 000000000000..16cf5e667fa2
> --- /dev/null
> +++ b/systemd/Makefile.am
> @@ -0,0 +1,32 @@
> +## Process this file with automake to produce Makefile.in
> +
> +MAINTAINERCLEANFILES = Makefile.in
> +
> +unit_files =  \
> +    nfs-blkmap.target \
> +    nfs-client.target \
> +    \
> +    auth-rpcgss-module.service \
> +    nfs-blkmap.service \
> +    nfs-config.service \
> +    nfs-idmapd.service \
> +    nfs-mountd.service \
> +    nfs-server.service \
> +    nfs-utils.service \
> +    rpc-gssd.service \
> +    rpc-statd-notify.service \
> +    rpc-statd.service \
> +    rpc-svcgssd.service \
> +    \
> +    proc-fs-nfsd.mount \
> +    var-lib-nfs-rpc_pipefs.mount
> +
> +EXTRA_DIST = $(unit_files)
> +
> +unit_dir = /usr/lib/systemd/system
> +
> +if INSTALL_SYSTEMD
> +install-data-hook: $(unit_files)
> +	mkdir -p $(DESTDIR)/$(unitdir)
> +	cp $(unit_files) $(DESTDIR)/$(unitdir)
> +endif
> 
