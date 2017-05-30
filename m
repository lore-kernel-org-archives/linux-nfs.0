Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60574 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750758AbdE3Er7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 00:47:59 -0400
Date: Tue, 30 May 2017 10:17:54 +0530
From: Niels de Vos <ndevos@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@RedHat.com>, systemd-devel@freedesktop.org,
        linux-nfs@vger.kernel.org,
        Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option
 and systemd.
Message-ID: <20170530044754.GK3364@ndevos-x240.usersys.redhat.com>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87tw43fgrf.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 30, 2017 at 08:19:16AM +1000, NeilBrown wrote:
> 
> Systemd does not, and will not, support "bg" correctly.
> It has other, better, ways to handle "background" mounting.
> 
> Explain this.
> 
> See also https://github.com/systemd/systemd/issues/6046
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  utils/mount/nfs.man | 18 +++++++++++++++++-
>  1 file changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index cc6e992ed807..7e76492d454f 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -372,6 +372,21 @@ Alternatively these issues can be addressed
>  using an automounter (refer to
>  .BR automount (8)
>  for details).
> +.IP
> +When
> +.B systemd
> +is used to mount the filesystems listed in
> +.IR /etc/fstab ,
> +the
> +.B bg
> +option is not supported, and may be stripped from the option list.
> +Similar functionality can be achieved by providing the
> +.B x-system.automount
> +option.  This will cause
> +.B systemd
> +to attempt to mount the filesystem when the mountpoint is first
> +accessed, rather than during system boot.  The mount still happens in
> +the "background", though in a different way.
>  .TP 1.5i
>  .BR rdirplus " / " nordirplus
>  Selects whether to use NFS v3 or v4 READDIRPLUS requests.
> @@ -1810,7 +1825,8 @@ such as security negotiation, server referrals, and named attributes.
>  .BR rpc.idmapd (8),
>  .BR rpc.gssd (8),
>  .BR rpc.svcgssd (8),
> -.BR kerberos (1)
> +.BR kerberos (1),
> +.BR systemd.mount (5) .
>  .sp
>  RFC 768 for the UDP specification.
>  .br
> -- 
> 2.12.2
> 

I like this, it makes it so much easier for users to find the better
alternative.

FWIW,
Reviewed-by: Niels de Vos <ndevos@redha.com>

