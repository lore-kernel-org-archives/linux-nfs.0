Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52052 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751578AbdFFSH7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Jun 2017 14:07:59 -0400
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option and
 systemd.
To: NeilBrown <neilb@suse.com>
Cc: systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org,
        Lennart Poettering <lennart@poettering.net>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
Date: Tue, 6 Jun 2017 14:07:57 -0400
MIME-Version: 1.0
In-Reply-To: <87tw43fgrf.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 05/29/2017 06:19 PM, NeilBrown wrote:
> 
> Systemd does not, and will not, support "bg" correctly.
> It has other, better, ways to handle "background" mounting.
The only problem with this is bg mounts still work at least
up to 4.11 kernel... 

It appears there is a problem with a 4.12 kernel. The mount no 
longer errors out with ECONNREFUSED it just hangs in the 
kernel trying forever... It sounds like a bug to me but 
maybe that change was intentional.. Anna?? Trond???

So I'm a bit hesitant to commit this since not accurate, yet.

Finally, the whole idea of systemd randomly/silently 
strip off mount options is crazy... IMHO... 

Just because a concept that has been around for years
does not fix well in the systemd world it gets
rip out??? IDK... but I think we can do better than that.

Note, the 'bg' is used by clients that do want their
booting to hang by servers that are down so if the 
option is rip out, boots will start hang. This
will make it very difficult to debug since the bg
will still exist in fstab.  

Again, the whole concept of systemd messing with mounts options
is just not a good one... IMHO.. 

steved.

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
> 
