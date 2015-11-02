Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753122AbbKBMxl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2015 07:53:41 -0500
Subject: Re: [PATCH] nfs-utils: Substitute sbindir in systemd unit files.
To: Calvin Walton <calvin.walton@kepstin.ca>, linux-nfs@vger.kernel.org
References: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca>
 <1429638223-13852-1-git-send-email-calvin.walton@kepstin.ca>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56375CD4.3010806@RedHat.com>
Date: Mon, 2 Nov 2015 07:53:40 -0500
MIME-Version: 1.0
In-Reply-To: <1429638223-13852-1-git-send-email-calvin.walton@kepstin.ca>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, 

I'm finally getting around to looking at this and
I'm seen a couple issues...

On 04/21/2015 01:43 PM, Calvin Walton wrote:
> The systemd unit files now include the correct full paths to the
> executables when nfs-utils is configured with an alternate value
> for e.g. --prefix or --sbindir
> 
> Signed-off-by: Calvin Walton <calvin.walton@kepstin.ca>
> ---
> 
> Resend of the same patch, but this time generated with -M so the diff
> includes file moves; this should make it a bit easier to review.
> 
>  .gitignore                                         |  8 ++++++
>  systemd/Makefile.am                                | 31 ++++++++++++----------
>  .../{nfs-blkmap.service => nfs-blkmap.service.in}  |  2 +-
>  .../{nfs-idmapd.service => nfs-idmapd.service.in}  |  2 +-
>  .../{nfs-mountd.service => nfs-mountd.service.in}  |  2 +-
>  .../{nfs-server.service => nfs-server.service.in}  | 12 ++++-----
>  systemd/{rpc-gssd.service => rpc-gssd.service.in}  |  2 +-
>  ...-notify.service => rpc-statd-notify.service.in} |  2 +-
>  .../{rpc-statd.service => rpc-statd.service.in}    |  2 +-
>  ...{rpc-svcgssd.service => rpc-svcgssd.service.in} |  2 +-
>  10 files changed, 38 insertions(+), 27 deletions(-)
>  rename systemd/{nfs-blkmap.service => nfs-blkmap.service.in} (88%)
>  rename systemd/{nfs-idmapd.service => nfs-idmapd.service.in} (86%)
>  rename systemd/{nfs-mountd.service => nfs-mountd.service.in} (86%)
>  rename systemd/{nfs-server.service => nfs-server.service.in} (78%)
>  rename systemd/{rpc-gssd.service => rpc-gssd.service.in} (90%)
>  rename systemd/{rpc-statd-notify.service => rpc-statd-notify.service.in} (90%)
>  rename systemd/{rpc-statd.service => rpc-statd.service.in} (87%)
>  rename systemd/{rpc-svcgssd.service => rpc-svcgssd.service.in} (91%)
> 
> diff --git a/.gitignore b/.gitignore
> index 5164637..4776b04 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -69,6 +69,14 @@ tests/nsm_client/nlm_sm_inter_clnt.c
>  tests/nsm_client/nlm_sm_inter_svc.c
>  tests/nsm_client/nlm_sm_inter_xdr.c
>  utils/nfsidmap/nfsidmap
> +systemd/nfs-blkmap.service
> +systemd/nfs-idmapd.service
> +systemd/nfs-mountd.service
> +systemd/nfs-server.service
> +systemd/rpc-gssd.service
> +systemd/rpc-statd-notify.service
> +systemd/rpc-statd.service
> +systemd/rpc-svcgssd.service
>  # cscope database files
>  cscope.*
>  # generic editor backup et al
> diff --git a/systemd/Makefile.am b/systemd/Makefile.am
> index fbcabb1..ec7e09b 100644
> --- a/systemd/Makefile.am
> +++ b/systemd/Makefile.am
> @@ -2,30 +2,33 @@
>  
>  MAINTAINERCLEANFILES = Makefile.in
>  
> -unit_files =  \
> +if INSTALL_SYSTEMD
> +dist_unit_DATA = \
>      nfs-client.target \
>      \
>      auth-rpcgss-module.service \
> -    nfs-blkmap.service \
>      nfs-config.service \
> +    nfs-utils.service \
> +    \
> +    proc-fs-nfsd.mount \
> +    var-lib-nfs-rpc_pipefs.mount
> +
> +unit_DATA = \
> +    nfs-blkmap.service \
>      nfs-idmapd.service \
>      nfs-mountd.service \
>      nfs-server.service \
> -    nfs-utils.service \
>      rpc-gssd.service \
>      rpc-statd-notify.service \
>      rpc-statd.service \
> -    rpc-svcgssd.service \
> -    \
> -    proc-fs-nfsd.mount \
> -    var-lib-nfs-rpc_pipefs.mount
> +    rpc-svcgssd.service
>  
> -EXTRA_DIST = $(unit_files)
> +CLEANFILES = $(unit_DATA)
This beginning part of the patch no longer applies
which is my fault... :-( 
>  
> -unit_dir = /usr/lib/systemd/system
> -
> -if INSTALL_SYSTEMD
> -install-data-hook: $(unit_files)
But after making the patch apply cleanly the scripts
no longer get installed and I believe its 
because you took out the above rule. 

> -	mkdir -p $(DESTDIR)/$(unitdir)
> -	cp $(unit_files) $(DESTDIR)/$(unitdir)
> +EXTRA_DIST = $(unit_DATA:service=.service.in)
>  endif
> +
> +SUFFIXES = .service.in .service
> +.service.in.service:
> +	$(SED) -e 's,[@]sbindir[@],$(sbindir),g' \
> +		< $< > $@

The rest of the patches all applied cleanly

steved.
