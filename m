Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gardel.0pointer.net ([85.214.157.71]:45714 "EHLO
        gardel.0pointer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751851AbdE3MnP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 May 2017 08:43:15 -0400
Date: Tue, 30 May 2017 14:43:12 +0200
From: Lennart Poettering <lennart@poettering.net>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@RedHat.com>, systemd-devel@freedesktop.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option
 and systemd.
Message-ID: <20170530124311.GA19096@gardel-login>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87tw43fgrf.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 30.05.17 08:19, NeilBrown (neilb@suse.com) wrote:

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

The option is called "x-systemd.automount", i.e. one more "d".

> +option.  This will cause
> +.B systemd
> +to attempt to mount the filesystem when the mountpoint is first
> +accessed, rather than during system boot.  The mount still happens in
> +the "background", though in a different way.

Looks good to me otherwise!

Lennart

-- 
Lennart Poettering, Red Hat
