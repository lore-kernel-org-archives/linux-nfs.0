Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40887 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454AbbFZNVp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jun 2015 09:21:45 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 52D5E45AA14
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2015 13:21:45 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (unused [10.10.50.112] (may be forged))
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t5QDLiZp016960
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2015 09:21:44 -0400
Message-ID: <558D51E8.4070001@RedHat.com>
Date: Fri, 26 Jun 2015 09:21:44 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs-server: Use rpcbind.service instead of rpbind.target
References: <1435245381-25085-1-git-send-email-steved@redhat.com>
In-Reply-To: <1435245381-25085-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/25/2015 11:16 AM, Steve Dickson wrote:
> To trigger the systemd socket activation support
> in rpcbind, nfs-service needs to Requires/After
> rpcbind.service instead of rpbind.target
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  systemd/nfs-server.service | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index db801cb..12b02f2 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -1,13 +1,13 @@
>  [Unit]
>  Description=NFS server and services
>  DefaultDependencies=no
> -Requires= network.target proc-fs-nfsd.mount rpcbind.target
> +Requires= network.target proc-fs-nfsd.mount rpcbind.service
>  Requires= nfs-mountd.service
>  Wants=rpc-statd.service nfs-idmapd.service
>  Wants=rpc-statd-notify.service
>  
>  After= local-fs.target
> -After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
> +After= network.target proc-fs-nfsd.mount rpcbind.service nfs-mountd.service
>  After= nfs-idmapd.service rpc-statd.service
>  Before= rpc-statd-notify.service
>  
> 
