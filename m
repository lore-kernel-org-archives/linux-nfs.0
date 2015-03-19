Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54782 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753384AbbCSSVI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2015 14:21:08 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t2JIL8vU009557
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2015 14:21:08 -0400
Received: from smallhat.boston.devel.redhat.com (smallhat.boston.devel.redhat.com [10.19.60.65])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t2JIL8Ax031920
	for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2015 14:21:08 -0400
Message-ID: <550B1394.6040400@RedHat.com>
Date: Thu, 19 Mar 2015 14:21:08 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs-blkmap.service: add EnvironmentFile directive
References: <1425756514-22118-1-git-send-email-steved@redhat.com>
In-Reply-To: <1425756514-22118-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/07/2015 02:28 PM, Steve Dickson wrote:
> Fixes: https://bugzilla.linux-nfs.org/show_bug.cgi?id=281
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  systemd/nfs-blkmap.service | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
> index f470e3d..8ad3b03 100644
> --- a/systemd/nfs-blkmap.service
> +++ b/systemd/nfs-blkmap.service
> @@ -13,4 +13,5 @@ PartOf=nfs-utils.service
>  [Service]
>  Type=forking
>  PIDFile=/var/run/blkmapd.pid
> +EnvironmentFile=-/run/sysconfig/nfs-utils
>  ExecStart=/usr/sbin/blkmapd $BLKMAPDARGS
> 
