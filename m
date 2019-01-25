Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 658E2C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 16:44:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 25EA5218CD
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 16:44:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728503AbfAYQoQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 11:44:16 -0500
Received: from mx1.redhat.com ([209.132.183.28]:59952 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726321AbfAYQoP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Jan 2019 11:44:15 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3E7DCA82C;
        Fri, 25 Jan 2019 16:44:15 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-117-181.phx2.redhat.com [10.3.117.181])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E349E166AC;
        Fri, 25 Jan 2019 16:44:14 +0000 (UTC)
Subject: Re: [PATCH] systemd: rpc_pipefs.target use BindsTo= instead of
 Requires=
To:     Yongcheng Yang <yongcheng.yang@gmail.com>
Cc:     linux-nfs@vger.kernel.org
References: <20190125083302.3346-1-yongcheng.yang@gmail.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <96be9630-a4bd-0f4c-65ab-4f008134c009@RedHat.com>
Date:   Fri, 25 Jan 2019 11:44:14 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190125083302.3346-1-yongcheng.yang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 25 Jan 2019 16:44:15 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello Yongcheng,

On 1/25/19 3:33 AM, Yongcheng Yang wrote:
> The rpc_pipefs.target should enter inactive state if
> var-lib-nfs-rpc_pipefs.mount is stopped. Otherwise,
> services depending rpc_pipefs.target (e.g. nfs-idmapd)
> fail to start after /var/lib/nfs/rpc_pipefs unmounted
> 
> Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
> ---
> 
> Reproducing steps:
> $ systemctl stop nfs-idmapd
> $ umount /var/lib/nfs/rpc_pipefs
> $ systemctl start nfs-idmapd
I look at things like this and I think there real
fix here is... Just don't do that! :-) 

Now I'm sure the patch works... but... why in the world would anybody 
unmount /var/lib/nfs/rpc_pipefs with NFS daemons running? 

Unless you are some mad QA person trying to destroy the world! ;-) 

steved.
> 
> Thanks,
> Yongcheng
> 
>  systemd/rpc_pipefs.target | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/systemd/rpc_pipefs.target b/systemd/rpc_pipefs.target
> index 01d4d27..5ce3981 100644
> --- a/systemd/rpc_pipefs.target
> +++ b/systemd/rpc_pipefs.target
> @@ -1,3 +1,3 @@
>  [Unit]
> -Requires=var-lib-nfs-rpc_pipefs.mount
> +BindsTo=var-lib-nfs-rpc_pipefs.mount
>  After=var-lib-nfs-rpc_pipefs.mount
> 
