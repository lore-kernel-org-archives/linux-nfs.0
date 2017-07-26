Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47222 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750907AbdGZSFa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Jul 2017 14:05:30 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D6C5CA23EC
        for <linux-nfs@vger.kernel.org>; Wed, 26 Jul 2017 18:05:29 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] systemd: add a blurb about masking rpc-gssd to
 the man page
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <87a83wyi00.fsf@notabene.neil.brown.name>
 <20170725151920.21760-1-smayhew@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <3e570175-18b3-c257-dce8-6109c5ca4e71@RedHat.com>
Date: Wed, 26 Jul 2017 14:05:28 -0400
MIME-Version: 1.0
In-Reply-To: <20170725151920.21760-1-smayhew@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/25/2017 11:19 AM, Scott Mayhew wrote:
> This is helpful for users that have a krb5.keytab but do not want to use
> secure NFS.  Also fixed a typo that appears earlier on the page.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed!

steved.

> ---
>  systemd/nfs.systemd.man | 18 ++++++++++++++----
>  1 file changed, 14 insertions(+), 4 deletions(-)
> 
> diff --git a/systemd/nfs.systemd.man b/systemd/nfs.systemd.man
> index 01801eb..46b476a 100644
> --- a/systemd/nfs.systemd.man
> +++ b/systemd/nfs.systemd.man
> @@ -79,7 +79,7 @@ unit should be enabled.
>  Several other units which might be considered to be optional, such as
>  .I rpc-gssd.service
>  are careful to only start if the required configuration file exists.
> -.I rpc-gsdd.service
> +.I rpc-gssd.service
>  will not start if the
>  .I krb5.keytab
>  file does not exist (typically in
> @@ -120,10 +120,11 @@ be needed to reduce system load to an absolute minimum, or to reduce
>  attack surface by not running daemons that are not absolutely
>  required.
>  .PP
> -Two particular services which this can apply to are
> -.I rpcbind
> +Three particular services which this can apply to are
> +.IR rpcbind ,
> +.IR idmapd ,
>  and
> -.IR idmapd .
> +.IR rpc-gssd .
>  .I rpcbind
>  is not part of the
>  .I nfs-utils
> @@ -155,6 +156,15 @@ is not needed and not wanted, it can be masked with
>  .RS
>  .B systemctl mask idmapd
>  .RE
> +.I rpc-gssd
> +is assumed to be needed if the
> +.I krb5.keytab
> +file is present.  If a site needs this file present but does not want
> +.I rpc-gssd
> +running, it can be masked with
> +.RS
> +.B systemctl mask rpc-gssd
> +.RE
>  .SH FILES
>  /etc/nfs.conf
>  .br
> 
