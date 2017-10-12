Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16593 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751394AbdJLOUr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Oct 2017 10:20:47 -0400
Subject: Re: [nfs-utils PATCH] Add RemainAfterExit to two services.
To: NeilBrown <neilb@suse.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <877ew90z6j.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <e3067316-9c4e-bdb8-39db-bc4a9c29ca15@RedHat.com>
Date: Thu, 12 Oct 2017 10:20:46 -0400
MIME-Version: 1.0
In-Reply-To: <877ew90z6j.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/05/2017 10:48 PM, NeilBrown wrote:
> 
> Both auth-rpcgss-module and rpc-statd-notify only
> ever need to be run once - the effect they have
> is permanent.
> We can give this information to systemd by setting
> RemainAfterExit=yes
> This avoids the minor cost of running them a second time
> if something "Wants" either service after it was first run,
> (e.g. both client and server startup can Want these),
> and avoids systemd complaining that it restarts to fast
> if multiple Wants happen at nearly the same time.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed...

steved.
> ---
>  systemd/auth-rpcgss-module.service | 1 +
>  systemd/rpc-statd-notify.service   | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/systemd/auth-rpcgss-module.service b/systemd/auth-rpcgss-module.service
> index 5241f7b5d58e..4548283377d0 100644
> --- a/systemd/auth-rpcgss-module.service
> +++ b/systemd/auth-rpcgss-module.service
> @@ -14,3 +14,4 @@ ConditionPathExists=/etc/krb5.keytab
>  [Service]
>  Type=oneshot
>  ExecStart=/sbin/modprobe -q auth_rpcgss
> +RemainAfterExit=yes
> diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
> index 687fe31140c0..aad4c0d29efe 100644
> --- a/systemd/rpc-statd-notify.service
> +++ b/systemd/rpc-statd-notify.service
> @@ -13,3 +13,4 @@ PartOf=nfs-utils.service
>  [Service]
>  Type=forking
>  ExecStart=-/usr/sbin/sm-notify
> +RemainAfterExit=yes
> 
