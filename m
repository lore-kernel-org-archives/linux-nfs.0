Return-Path: <SteveD@redhat.com>
Subject: Re: [PATCH - nfs-utils] systemd: ensure nfs-config service is re-run
 as needed.
To: NeilBrown <neilb@suse.com>
References: <87fuvrfbof.fsf@notabene.neil.brown.name>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56E9A492.1090106@RedHat.com>
Date: Wed, 16 Mar 2016 14:23:14 -0400
MIME-Version: 1.0
In-Reply-To: <87fuvrfbof.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
List-ID: <linux-nfs.vger.kernel.org>



On 03/15/2016 09:34 PM, NeilBrown wrote:
> 
> The nfs-config service translates distro-specific startup
> configuration into "environment" variable read and used
> by systemd unit files.
> 
> Currently it is only run once, so subsequent changes to the
> distro-specific files do not take effect when an nfs service is
> restarted.
> 
> If we change "RemainAfterExit=yes" to "RemainAfterExit=no" then the
> service will be restarted before any dependant service is started, so
> the environment file will always be up to date.
> 
> Reported-and-tested-by: Benjamin Coddington <bcodding@redhat.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed... Nice Work!!! 

steved.
> ---
>  systemd/nfs-config.service | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/systemd/nfs-config.service b/systemd/nfs-config.service
> index 7f653058f424..e0a7f83314f5 100644
> --- a/systemd/nfs-config.service
> +++ b/systemd/nfs-config.service
> @@ -5,5 +5,9 @@ DefaultDependencies=no
>  
>  [Service]
>  Type=oneshot
> -RemainAfterExit=yes
> +# This service needs to run any time any nfs service
> +# is started, so changes to local config files get
> +# incorporated.  Having "RemainAfterExit=no" (the default)
> +# ensures this happens.
> +RemainAfterExit=no
>  ExecStart=/usr/lib/systemd/scripts/nfs-utils_env.sh
> 
