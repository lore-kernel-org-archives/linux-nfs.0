Return-Path: <SRS0=EZRz=A4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,NICE_REPLY_A,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D87C1C433DF
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Jul 2020 13:56:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B339620734
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Jul 2020 13:56:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Z2wz37yQ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726858AbgGQN4F (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 17 Jul 2020 09:56:05 -0400
Received: from us-smtp-1.mimecast.com ([207.211.31.81]:29968 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726780AbgGQN4F (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jul 2020 09:56:05 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1594994164;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=MGPXeUCC3DAsNQYvnpj9SdrLZxgbOeEtKmgppgyso6U=;
        b=Z2wz37yQc1rE/NgKqYKwvcwwkyPp4XMzlUuDT+Vpp3aSU3ZLf3x4scZ8zDDMvC0MCDMl88
        SFdhJssrz+FyTHdAtRVq00NybBEnuDW328kzUuGuGaTch3ae6RZLSrbG9nzE6TP+GoB6dP
        MQQiLJwV/mBX+aABRvl+pCUHgQsqt+k=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-513-Xho8HqiTPDCZ1GgpznWKHg-1; Fri, 17 Jul 2020 09:56:00 -0400
X-MC-Unique: Xho8HqiTPDCZ1GgpznWKHg-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 26716100CCC1;
        Fri, 17 Jul 2020 13:55:59 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-113-147.phx2.redhat.com [10.3.113.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AFA0E7B431;
        Fri, 17 Jul 2020 13:55:55 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: systemd: nfs-server.service: Cleanup extra
 whitespaces
To:     Salvatore Bonaccorso <carnil@debian.org>, linux-nfs@vger.kernel.org
Cc:     NeilBrown <neilb@suse.de>, Scott Mayhew <smayhew@redhat.com>
References: <20200628092441.81529-1-carnil@debian.org>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <c0223681-6ae1-a163-af54-bd560c11b571@RedHat.com>
Date:   Fri, 17 Jul 2020 09:55:55 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
In-Reply-To: <20200628092441.81529-1-carnil@debian.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 6/28/20 5:24 AM, Salvatore Bonaccorso wrote:
> Although whitespaces immediately before or after the "=" are ignored,
> removing the extra whitespaces in some of the key=value assignments
> makes the style more consistent.
> 
> At least since systemd v242-rc1[1] this has been clarified that
> whitespaces immediately before and after the "=" are allowed.
> 
>  [1] https://github.com/systemd/systemd/commit/170342c90be07f418ab786718d95ef76289126a0
> 
> Signed-off-by: Salvatore Bonaccorso <carnil@debian.org>
Committed... (tag: nfs-utils-2-5-2-rc2)

steved.
> ---
>  systemd/nfs-server.service | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 24118d693965..06c1adb71692 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -1,18 +1,18 @@
>  [Unit]
>  Description=NFS server and services
>  DefaultDependencies=no
> -Requires= network.target proc-fs-nfsd.mount
> -Requires= nfs-mountd.service
> +Requires=network.target proc-fs-nfsd.mount
> +Requires=nfs-mountd.service
>  Wants=rpcbind.socket network-online.target
>  Wants=rpc-statd.service nfs-idmapd.service
>  Wants=rpc-statd-notify.service
>  Wants=nfsdcld.service
>  
> -After= network-online.target local-fs.target
> -After= proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
> -After= nfs-idmapd.service rpc-statd.service
> -After= nfsdcld.service
> -Before= rpc-statd-notify.service
> +After=network-online.target local-fs.target
> +After=proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
> +After=nfs-idmapd.service rpc-statd.service
> +After=nfsdcld.service
> +Before=rpc-statd-notify.service
>  
>  # GSS services dependencies and ordering
>  Wants=auth-rpcgss-module.service
> 

