Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39540 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753773AbcHXOam (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Aug 2016 10:30:42 -0400
Subject: Re: [PATCH/nfs-utils] Make location of nfs-utils_env.sh configurable.
To: NeilBrown <neilb@suse.com>
References: <8737lvglvn.fsf@notabene.neil.brown.name>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <206c39a6-4d22-4285-6227-0969ab747923@RedHat.com>
Date: Wed, 24 Aug 2016 10:30:40 -0400
MIME-Version: 1.0
In-Reply-To: <8737lvglvn.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/23/2016 06:29 PM, NeilBrown wrote:
> 
> A recent patch moved this file to /usr/libexec/...
> That directory isn't universal, and doesn't exist on openSUSE or
> Debian for example.
> So change it to use the $libexecdir directory determined by configure
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed! 
> ---
> 
> Hi Steve,
>  thanks for processing the server startup patches nice and promptly,
>  and for fixing the little details.
>  Here is another patches:-)  I really should have tried out the latest
>  nfs-utils in openSUSE *before* the release instead of just after.
>  Maybe next time.
Sorry about that... I did just assumed that path existed in all distros 
It guess that was a bad assumption :-(  
> 
>  It took me a while to get this configure.ac magic to work, but it does
>  work nicely for me.  I haven't testing it on a RH distro, but I think
>  it should default to the same behavior as before.
Nice work!!! We can now do the same thing to make the keytab 
configurable in rpc-gssd.service. I've had a compile complaints
about that. 

It's too bad systemd does not have someway of configuring paths
in the [Unit] section so we could make changes like this
"on the fly" instead of at compile time.


> 
>  Note that there is a 'rename' in this patch.  Presumably "git am" will
>  handle that correctly.  Worth verifying though.
Noted... thanks!

steved.
> 
> Thanks,
> NeilBrown
> 
> 
>  configure.ac                                          | 6 ++++++
>  systemd/{nfs-config.service => nfs-config.service.in} | 2 +-
>  2 files changed, 7 insertions(+), 1 deletion(-)
>  rename systemd/{nfs-config.service => nfs-config.service.in} (86%)
> 
> diff --git a/configure.ac b/configure.ac
> index 1daf5b8130e2..4fb108fb68d2 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -511,8 +511,14 @@ AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
>  # Make sure that $ACLOCAL_FLAGS are used during a rebuild
>  AC_SUBST([ACLOCAL_AMFLAGS], ["-I $ac_macro_dir \$(ACLOCAL_FLAGS)"])
>  
> +# make libexecdir available for substituion in config files
> +# 2 "evals" needed late to expand variable names.
> +AC_SUBST([_libexecdir])
> +AC_CONFIG_COMMANDS_PRE([eval eval _libexecdir=$libexecdir])
> +
>  AC_CONFIG_FILES([
>  	Makefile
> +	systemd/nfs-config.service
>  	linux-nfs/Makefile
>  	support/Makefile
>  	support/export/Makefile
> diff --git a/systemd/nfs-config.service b/systemd/nfs-config.service.in
> similarity index 86%
> rename from systemd/nfs-config.service
> rename to systemd/nfs-config.service.in
> index bd69e84a7233..e89dc54209aa 100644
> --- a/systemd/nfs-config.service
> +++ b/systemd/nfs-config.service.in
> @@ -10,4 +10,4 @@ Type=oneshot
>  # incorporated.  Having "RemainAfterExit=no" (the default)
>  # ensures this happens.
>  RemainAfterExit=no
> -ExecStart=/usr/libexec/nfs-utils/nfs-utils_env.sh
> +ExecStart=@_libexecdir@/nfs-utils/nfs-utils_env.sh
> 
