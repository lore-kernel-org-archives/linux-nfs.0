Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30056 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751270AbaIVT0G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 15:26:06 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8MJQ6Th014162
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2014 15:26:06 -0400
Date: Mon, 22 Sep 2014 15:26:03 -0400
From: Simo Sorce <simo@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140922152603.75005941@willson.usersys.redhat.com>
In-Reply-To: <1411413608-16462-2-git-send-email-steved@redhat.com>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
	<1411413608-16462-2-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 22 Sep 2014 15:20:07 -0400
Steve Dickson <steved@redhat.com> wrote:

> Added the gssproxy.service to both the Wants= and
> Atfers= lines, before the rpc-svcgssd.service. There
> are  ConditionPathExists= lines in the rpc-svcgssd.service
> unit which will stop the rpc.svcgssd daemon from
> starting when the gssproxy daemon is already running.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  systemd/nfs-server.service | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 2fa7387..c740fa2 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -2,12 +2,13 @@
>  Description=NFS server and services
>  Requires= network.target proc-fs-nfsd.mount rpcbind.target
>  Requires= nfs-mountd.service
> -Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service
> rpc-svcgssd.service +Wants=rpc-statd.service nfs-idmapd.service 
> +Wants=rpc-gssd.service  
>  Wants=rpc-statd-notify.service
>  
>  After= network.target proc-fs-nfsd.mount rpcbind.target
> nfs-mountd.service After= nfs-idmapd.service rpc-statd.service
> -After= rpc-gssd.service rpc-svcgssd.service
> +After= rpc-gssd.service gssproxy.service rpc-svcgssd.service
>  Before= rpc-statd-notify.service
>  
>  Wants=nfs-config.service

I think you really need to insure that the modules are loaded before
any of the server services are started, perhaps adding a unit file that
exec's modprobe and has "Before: gssproxy.service rpc-svcgssd.service"
in it ?

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York
