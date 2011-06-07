Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab1FGUVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 16:21:49 -0400
Message-ID: <4DEE885A.4080400@RedHat.com>
Date: Tue, 07 Jun 2011 16:21:46 -0400
From: Steve Dickson <SteveD@redhat.com>
To: NeilBrown <neilb@suse.de>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Subject: [PATCH] Document "-n" for svcgssd.
References: <20110602171814.1bd1824c@notabene.brown>
In-Reply-To: <20110602171814.1bd1824c@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/02/2011 03:18 AM, NeilBrown wrote:
> From 32a56b81190085f681a3bc3dbb984cdb0c8d68d4 Mon Sep 17 00:00:00 2001
> From: Neil Brown <neilb@suse.de>
> Date: Thu, 2 Jun 2011 17:14:39 +1000
> Subject: [PATCH] Document "-n" for svcgssd.
> 
> The man page doesn't mention the "-n" flag.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
> I made the text up based on the doco for gss_acquire_cred.
> If anyone actually understands this stuff they should feel free
> to re-write the documentation of "-n" below.
> Thanks
> NeilBrown
Committed...

steved.
> 
> 
> 
>  utils/gssd/svcgssd.man |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/gssd/svcgssd.man b/utils/gssd/svcgssd.man
> index 1c7bb32..7b2de6b 100644
> --- a/utils/gssd/svcgssd.man
> +++ b/utils/gssd/svcgssd.man
> @@ -6,7 +6,7 @@
>  .SH NAME
>  rpc.svcgssd \- server-side rpcsec_gss daemon
>  .SH SYNOPSIS
> -.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-p principal]"
> +.B "rpc.svcgssd [-n] [-v] [-r] [-i] [-f] [-p principal]"
>  .SH DESCRIPTION
>  The rpcsec_gss protocol gives a means of using the gss-api generic security
>  api to provide security for protocols using rpc (in particular, nfs).  Before
> @@ -37,7 +37,14 @@ If the nfsidmap library supports setting debug level,
>  increases the verbosity of the output (can be specified multiple times).
>  .TP
>  .B -p
> -Use \fIprincipal\fR instead of the default nfs/host.domain.
> +Use \fIprincipal\fR instead of the default
> +.RI nfs/ FQDN @ REALM .
> +.TP
> +.B -n
> +Use the system default credentials
> +.RI (host/ FQDN @ REALM )
> +rather than the default
> +.RI nfs/ FQDN @ REALM .
>  .SH SEE ALSO
>  .BR rpc.gssd(8),
>  .SH AUTHORS
