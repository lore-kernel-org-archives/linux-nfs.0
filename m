Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751977AbaLMObM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 13 Dec 2014 09:31:12 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBDEVCH0023787
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Sat, 13 Dec 2014 09:31:12 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-59-73.rdu2.redhat.com [10.10.59.73])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBDEVB7G020940
	for <linux-nfs@vger.kernel.org>; Sat, 13 Dec 2014 09:31:12 -0500
Message-ID: <548C4DAF.5050902@RedHat.com>
Date: Sat, 13 Dec 2014 09:31:11 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] systemd: added the $BLKMAPDARGS var to the nfs-blkmap
 service
References: <1418245335-8935-1-git-send-email-steved@redhat.com>
In-Reply-To: <1418245335-8935-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/10/2014 04:02 PM, Steve Dickson wrote:
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  systemd/nfs-blkmap.service | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
Committed... 

steved.

> 
> diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
> index 68cc9e9..f470e3d 100644
> --- a/systemd/nfs-blkmap.service
> +++ b/systemd/nfs-blkmap.service
> @@ -13,4 +13,4 @@ PartOf=nfs-utils.service
>  [Service]
>  Type=forking
>  PIDFile=/var/run/blkmapd.pid
> -ExecStart=/usr/sbin/blkmapd
> +ExecStart=/usr/sbin/blkmapd $BLKMAPDARGS
> 
