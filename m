Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:46996 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752518AbeFEOpY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Jun 2018 10:45:24 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4630D4075390
        for <linux-nfs@vger.kernel.org>; Tue,  5 Jun 2018 14:45:24 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] Fixed missed read of config file by nolockmgr
 (bz 1413272)
To: Rinku Kothiya <rkothiya@redhat.com>, linux-nfs@vger.kernel.org
References: <1527665983-17319-1-git-send-email-rkothiya@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <7ce32be1-9e29-591a-d02c-dd78b5bf240e@RedHat.com>
Date: Tue, 5 Jun 2018 10:45:23 -0400
MIME-Version: 1.0
In-Reply-To: <1527665983-17319-1-git-send-email-rkothiya@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/30/2018 03:39 AM, Rinku Kothiya wrote:
> Signed-off-by: Rinku Kothiya <rkothiya@redhat.com>
> Resolves: bz1413272
> ---
>  nfs-config.service | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/nfs-config.service b/nfs-config.service
> index 7f65305..f16b2ed 100644
> --- a/nfs-config.service
> +++ b/nfs-config.service
> @@ -2,6 +2,8 @@
>  Description=Preprocess NFS configuration
>  After=local-fs.target
>  DefaultDependencies=no
> +PartOf=nfs-server.service
> +Restart=always
>  
>  [Service]
>  Type=oneshot
> 
This file was removed from upstream when the configuration
moved to /etc/nfs.conf. Thanks though...  

steved.
