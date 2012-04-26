Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59171 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759166Ab2DZUHF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 16:07:05 -0400
Message-ID: <4F99AADC.5000904@RedHat.com>
Date: Thu, 26 Apr 2012 16:06:52 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Nick Alcock <nix@esperi.org.uk>
CC: linux-nfs@vger.kernel.org, Nick Alcock <nick.alcock@oracle.com>
Subject: Re: [PATCH 2/4] Make svc_auth_none always available.
References: <1328472138-25750-1-git-send-email-nix@esperi.org.uk> <1328472138-25750-2-git-send-email-nix@esperi.org.uk>
In-Reply-To: <1328472138-25750-2-git-send-email-nix@esperi.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/05/2012 03:02 PM, Nick Alcock wrote:
> From: Nick Alcock <nick.alcock@oracle.com>
> 
> svc_auth_none is only included in the build when GSS is compiled in, but is used
> by svc_auth_unix, which is unconditionally included.
> 
> Include svc_auth_none unconditionally as well.
> 
> Signed-off-by: Nick Alcock <nick.alcock@oracle.com>
> ---
>  src/Makefile.am |    7 +++----
>  1 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/src/Makefile.am b/src/Makefile.am
> index 6731ff9..509cf61 100644
> --- a/src/Makefile.am
> +++ b/src/Makefile.am
> @@ -48,8 +48,8 @@ libtirpc_la_SOURCES = auth_none.c auth_unix.c authunix_prot.c bindresvport.c cln
>          getrpcport.c mt_misc.c pmap_clnt.c pmap_getmaps.c pmap_getport.c \
>          pmap_prot.c pmap_prot2.c pmap_rmt.c rpc_prot.c rpc_commondata.c \
>          rpc_callmsg.c rpc_generic.c rpc_soc.c rpcb_clnt.c rpcb_prot.c \
> -        rpcb_st_xdr.c svc.c svc_auth.c svc_dg.c svc_auth_unix.c svc_generic.c \
> -        svc_raw.c svc_run.c svc_simple.c svc_vc.c getpeereid.c \
> +        rpcb_st_xdr.c svc.c svc_auth.c svc_dg.c svc_auth_unix.c svc_auth_none.c \
> +        svc_generic.c svc_raw.c svc_run.c svc_simple.c svc_vc.c getpeereid.c \
>          auth_time.c auth_des.c authdes_prot.c
>  
>  ## XDR
> @@ -57,8 +57,7 @@ libtirpc_la_SOURCES += xdr.c xdr_rec.c xdr_array.c xdr_float.c xdr_mem.c xdr_ref
>  
>  ## Secure-RPC
>  if GSS
> -    libtirpc_la_SOURCES += auth_gss.c authgss_prot.c svc_auth_gss.c \
> -		svc_auth_none.c
> +    libtirpc_la_SOURCES += auth_gss.c authgss_prot.c svc_auth_gss.c
>      libtirpc_la_LDFLAGS += $(GSSGLUE_LIBS)
>      libtirpc_la_CFLAGS = -DHAVE_RPCSEC_GSS $(GSSGLUE_CFLAGS)
>  endif
Committed...

steved.
