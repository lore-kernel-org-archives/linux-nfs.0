Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594AbbAOLT4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jan 2015 06:19:56 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t0FBJunM029215
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Jan 2015 06:19:56 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-51-251.rdu2.redhat.com [10.10.51.251])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t0FBJt7x032031
	for <linux-nfs@vger.kernel.org>; Thu, 15 Jan 2015 06:19:56 -0500
Message-ID: <54B7A25B.5000506@RedHat.com>
Date: Thu, 15 Jan 2015 06:19:55 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sm-notify: notify hosts in background
References: <1421265337-8438-1-git-send-email-steved@redhat.com>
In-Reply-To: <1421265337-8438-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/14/2015 02:55 PM, Steve Dickson wrote:
> sm-notify needs to notify hosts in background so the boot
> will not hang when the notified hosts do not answer.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  systemd/rpc-statd-notify.service | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.service
> index 6b13b32..3ce669e 100644
> --- a/systemd/rpc-statd-notify.service
> +++ b/systemd/rpc-statd-notify.service
> @@ -14,6 +14,5 @@ After=nfs-config.service
>  
>  [Service]
>  EnvironmentFile=-/run/sysconfig/nfs-utils
> -Type=oneshot
> -RemainAfterExit=yes
> +Type=forking
>  ExecStart=-/usr/sbin/sm-notify $SMNOTIFYARGS
> 
Committed... 
