Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62163 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170AbaI3LFH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2014 07:05:07 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8UB57bY021753
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 30 Sep 2014 07:05:07 -0400
Received: from smallhat.boston.devel.redhat.com (smallhat.boston.devel.redhat.com [10.19.60.65])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s8UB56JV031148
	for <linux-nfs@vger.kernel.org>; Tue, 30 Sep 2014 07:05:06 -0400
Message-ID: <542A8E62.1080408@RedHat.com>
Date: Tue, 30 Sep 2014 07:05:06 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs-client.target: Removed a ordering cycle with nfs-server.service
References: <1412004817-14432-1-git-send-email-steved@redhat.com>
In-Reply-To: <1412004817-14432-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/29/2014 11:33 AM, Steve Dickson wrote:
> On a VM that boots very fast and with out kerberos
> enabled a systemd ordering cycle happens between
> nfs-client and nfs-server units when both were
> enabled.
> 
> Having nfs-client start the gssd daemons in the
> same matter as the nfs-server does ('After=') seemed
> to eliminated the ordering cycle.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  systemd/nfs-client.target | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
> index 474f5e9..87a1ce8 100644
> --- a/systemd/nfs-client.target
> +++ b/systemd/nfs-client.target
> @@ -7,7 +7,7 @@ Wants=remote-fs-pre.target
>  # start that on demand if needed.
>  Wants=rpc-gssd.service rpc-svcgssd.service auth-rpcgss-module.service
>  Wants=nfs-blkmap.service rpc-statd-notify.service
> -Before=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
> +After=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
>  
>  [Install]
>  WantedBy=multi-user.target
> 
