Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbbKPUGK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2015 15:06:10 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id E23F4C076601
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2015 20:06:09 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-56-193.rdu2.redhat.com [10.10.56.193])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tAGK69gc031091
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2015 15:06:09 -0500
Subject: Re: [PATCH] systemd: Decouple the starting and stopping of
 rpcbind/nfs-server
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1447086783-17977-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <564A3730.60306@RedHat.com>
Date: Mon, 16 Nov 2015 15:06:08 -0500
MIME-Version: 1.0
In-Reply-To: <1447086783-17977-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/09/2015 11:33 AM, Steve Dickson wrote:
> Commit b98f2af15 introduced a regression that cause the
> starting and stop of rpcbind and the nfs-server to
> be depended on each other
> 
> The starting of the NFS server should start rpcbind
> but bring rpcbind down should not bring the NFS
> server down.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed.. 

steved.

> ---
>  systemd/nfs-server.service | 2 +-
>  systemd/rpc-statd.service  | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 12b02f2..317e5d6 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -1,7 +1,7 @@
>  [Unit]
>  Description=NFS server and services
>  DefaultDependencies=no
> -Requires= network.target proc-fs-nfsd.mount rpcbind.service
> +Requires= network.target proc-fs-nfsd.mount rpcbind.target
>  Requires= nfs-mountd.service
>  Wants=rpc-statd.service nfs-idmapd.service
>  Wants=rpc-statd-notify.service
> diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
> index 14604d7..f16ea42 100644
> --- a/systemd/rpc-statd.service
> +++ b/systemd/rpc-statd.service
> @@ -3,7 +3,7 @@ Description=NFS status monitor for NFSv2/3 locking.
>  DefaultDependencies=no
>  Conflicts=umount.target
>  Requires=nss-lookup.target rpcbind.target
> -After=network.target nss-lookup.target rpcbind.target
> +After=network.target nss-lookup.target rpcbind.service
>  
>  PartOf=nfs-utils.service
>  
> 
