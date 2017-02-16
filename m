Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57308 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751826AbdBPKW3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Feb 2017 05:22:29 -0500
Subject: Re: [PATCH] conffile: ignore empty environment variables.
To: NeilBrown <neilb@suse.com>
References: <87a89xwr0o.fsf@notabene.neil.brown.name>
Cc: Linux NFS Mailing <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <be4ee263-3a1c-9f32-9e5f-10eccd80eeb5@RedHat.com>
Date: Thu, 16 Feb 2017 05:22:29 -0500
MIME-Version: 1.0
In-Reply-To: <87a89xwr0o.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/07/2017 05:54 PM, NeilBrown wrote:
> conf_set() already refuses to set an empty value, so if
>   foo=
> appears in the config file, it will be ignored.
> This patch extends the policy to environment variables, so empty
> environment variables are treated as though they didn't exist.
>
> This means that a separate environment file (e.g. /etc/sysconfig/nfs)
> will be treated the same way whether it is:
>  - included in the [environment] section of /etc/nfs.conf
>  - sourced by the shell before running code
>  - sourced by the systemd EnvironmentFile directive.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed...

steved.
> ---
>  support/nfs/conffile.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index e717c1e39bab..203efd2aa602 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -533,7 +533,7 @@ retry:
>  				 * or from environment
>  				 */
>  				char *env = getenv(cb->value+1);
> -				if (env)
> +				if (env && *env)
>  					return env;
>  				section = "environment";
>  				tag = cb->value + 1;

