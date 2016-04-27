Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752656AbcD0Rct (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 13:32:49 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6A3FE78225
	for <linux-nfs@vger.kernel.org>; Wed, 27 Apr 2016 17:32:48 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-58-205.rdu2.redhat.com [10.10.58.205])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u3RHWlpS011426
	for <linux-nfs@vger.kernel.org>; Wed, 27 Apr 2016 13:32:48 -0400
Subject: Re: [PATCH] Move nfs-utils_env.sh to a more appropriate directory
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1458414669-26671-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <5720F7BF.2000504@RedHat.com>
Date: Wed, 27 Apr 2016 13:32:47 -0400
MIME-Version: 1.0
In-Reply-To: <1458414669-26671-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/19/2016 03:11 PM, Steve Dickson wrote:
> Currently nfs-utils_env.sh is installed in a
> directory that is own by systemd. They requested
> via https://bugzilla.redhat.com/show_bug.cgi?id=1303113
> to move the script into /usr/libexec/nfs-utils
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  systemd/README             | 2 +-
>  systemd/nfs-config.service | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/systemd/README b/systemd/README
> index bbd7790..7c43df8 100644
> --- a/systemd/README
> +++ b/systemd/README
> @@ -53,7 +53,7 @@ client and systemd cannot specify is two-pronged reverse dependency.
>  (i.e. stop this unit if none of these units are running)
>  
>  Distro specific commandline configuration can be provided by
> -installing a script /usr/lib/systemd/scripts/nfs-utils_env.sh
> +installing a script /usr/libexec/nfs-utils/nfs-utils_env.sh
>  This should write /run/sysconfig/nfs-utils based on configuration
>  information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
>  It is run once by nfs-config.service.
> diff --git a/systemd/nfs-config.service b/systemd/nfs-config.service
> index 4b206b5..bd69e84 100644
> --- a/systemd/nfs-config.service
> +++ b/systemd/nfs-config.service
> @@ -10,4 +10,4 @@ Type=oneshot
>  # incorporated.  Having "RemainAfterExit=no" (the default)
>  # ensures this happens.
>  RemainAfterExit=no
> -ExecStart=/usr/lib/systemd/scripts/nfs-utils_env.sh
> +ExecStart=/usr/libexec/nfs-utils/nfs-utils_env.sh
> 
