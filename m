Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44942 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753401AbbCSSUo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2015 14:20:44 -0400
Message-ID: <550B137C.5040509@RedHat.com>
Date: Thu, 19 Mar 2015 14:20:44 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
CC: Systemd Mailing List <systemd-devel@lists.freedesktop.org>,
        Eric Work <work.eric@gmail.com>
Subject: Re: [PATCH] systemd: Have rpc-statd-notify.service Require network.target
References: <1425407803-5278-1-git-send-email-steved@redhat.com>
In-Reply-To: <1425407803-5278-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/03/2015 01:36 PM, Steve Dickson wrote:
> Its been reported that having the rpc-statd-notify service
> depend on network.target instead network-online.target
> decrease boot times as much as 10 seconds on some
> installs
> 
> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1183293
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> Reported-by: Eric Work <work.eric@gmail.com>
Committed...

steved.

> ---
>  systemd/rpc-statd-notify.service |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
> index a655445..b608a14 100644
> --- a/systemd/rpc-statd-notify.service
> +++ b/systemd/rpc-statd-notify.service
> @@ -1,6 +1,6 @@
>  [Unit]
>  Description=Notify NFS peers of a restart
> -Requires=network-online.target
> +Requires=network.target
>  After=network.target nss-lookup.target
>  
>  # if we run an nfs server, it needs to be running before we
> 
