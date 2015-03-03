Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f50.google.com ([209.85.215.50]:43306 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734AbbCCTHB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2015 14:07:01 -0500
Received: by labgf13 with SMTP id gf13so14990139lab.10
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2015 11:07:00 -0800 (PST)
Date: Tue, 3 Mar 2015 22:06:57 +0300
From: Andrei Borzenkov <arvidjaar@gmail.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: Re: [systemd-devel] [PATCH] systemd: Have rpc-statd-notify.service
 Require network.target
Message-ID: <20150303220657.6ba6011b@opensuse.site>
In-Reply-To: <1425407803-5278-1-git-send-email-steved@redhat.com>
References: <1425407803-5278-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

В Tue,  3 Mar 2015 13:36:43 -0500
Steve Dickson <steved@redhat.com> пишет:

> Its been reported that having the rpc-statd-notify service
> depend on network.target instead network-online.target
> decrease boot times as much as 10 seconds on some
> installs
> 

If it does not need network when strting, it should not depend on
network at all. This will probably decrease boot time even more.

If it does need network, it should depend on network-online, this is
correct.

> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1183293
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> Reported-by: Eric Work <work.eric@gmail.com>
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

