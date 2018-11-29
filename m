Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94E40C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 19:36:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 688B22082F
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 19:36:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 688B22082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725883AbeK3Gmp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 01:42:45 -0500
Received: from mx1.redhat.com ([209.132.183.28]:54144 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725871AbeK3Gmo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 01:42:44 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 16FFA3078A56;
        Thu, 29 Nov 2018 19:36:14 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9F95519005;
        Thu, 29 Nov 2018 19:36:13 +0000 (UTC)
Subject: Re: [PATCH nfs-utils] systemd/rpc-statd.service - add
 IgnoreOnIsolate=yes
To:     NeilBrown <neilb@suse.com>
Cc:     linux-nfs@vger.kernel.org
References: <87bm69q2os.fsf@notabene.neil.brown.name>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <eb2b5354-80c0-b30f-ba6f-f2ab3457e7df@RedHat.com>
Date:   Thu, 29 Nov 2018 14:36:13 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <87bm69q2os.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 29 Nov 2018 19:36:14 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 11/27/18 10:52 PM, NeilBrown wrote:
> If you run
>   systemctl isolate multi-user.target
> then all services not needed by multi-user.target are stopped.
> This currently includes rpc-statd, which is a problem.
> 
> Systemd doesn't know that rpc-statd.service is needed by
> multi-user.target, or more accurately nfs-client.target, because
> sometimes it isn't.
> It is started dynamically by mount.nfs when a v3 or v2 filesystem
> is mounted (not when v4 is mounted) - so systemd doesn't see the connection.
> 
> mount units default to IgnoreOnIsolate=yes, as mounts are expected to be
> left mounted when you run "systemctl isolate ....".  As rpc-statd.service
> is started by a mount, and needed for some mounts, it makes sense for it
> to declare IgnoreOnIsolate=yes too.
> With this declaration in place rpc.statd remains running when
>   systemctl isolate multi-user.target
> is run.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed....

steved.

> ---
>  systemd/rpc-statd.service | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
> index f41ae2084f3c..1f4e6a8b92ab 100644
> --- a/systemd/rpc-statd.service
> +++ b/systemd/rpc-statd.service
> @@ -7,6 +7,7 @@ Wants=network-online.target
>  After=network-online.target nss-lookup.target rpcbind.socket
>  
>  PartOf=nfs-utils.service
> +IgnoreOnIsolate=yes
>  
>  [Service]
>  Environment=RPC_STATD_NO_NOTIFY=1
> -- 2.14.0.rc0.dirty
> 
