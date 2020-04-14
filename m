Return-Path: <SRS0=4kDZ=56=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EB74C2BA19
	for <linux-nfs@archiver.kernel.org>; Tue, 14 Apr 2020 14:27:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D2B562075E
	for <linux-nfs@archiver.kernel.org>; Tue, 14 Apr 2020 14:27:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="JrpIxJn+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2390737AbgDNO1S (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 14 Apr 2020 10:27:18 -0400
Received: from us-smtp-delivery-1.mimecast.com ([207.211.31.120]:46120 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S2390729AbgDNO1M (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2020 10:27:12 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1586874431;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=4H7TAKB4dm82Jdk9InJK6ckbKEcKsNBHOaf2lPjiQ58=;
        b=JrpIxJn+08EGuPQFTgydzQuVbB9egyTih+lo5p0gi0r0FDWxPP8y3daaZsR2HqNT9FQQNT
        fJdOmuyq+rz6SreTCZlbtGJJy+s9lJOKjjaCQ9CyRc2thMrjYjoR++NiTJ8snxdMIQhOF+
        9LNZcFXD60WWbqGevU7BLf89D+DH5y8=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-269-sCmWdXpCMWugIEzu6cdW_g-1; Tue, 14 Apr 2020 10:27:08 -0400
X-MC-Unique: sCmWdXpCMWugIEzu6cdW_g-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 74698DBA8;
        Tue, 14 Apr 2020 14:27:07 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-113-136.phx2.redhat.com [10.3.113.136])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2FDF210016EB;
        Tue, 14 Apr 2020 14:27:07 +0000 (UTC)
Subject: Re: [PATCH] nfsidmap: define NS_MAXMSG if undefined
To:     Rosen Penev <rosenp@gmail.com>, linux-nfs@vger.kernel.org
References: <20200404053642.2632532-1-rosenp@gmail.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <1cc2c337-68df-7890-5031-61ef36f96a84@RedHat.com>
Date:   Tue, 14 Apr 2020 10:27:06 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
In-Reply-To: <20200404053642.2632532-1-rosenp@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 4/4/20 1:36 AM, Rosen Penev wrote:
> uClibc-ng does not define it.
> 
> Signed-off-by: Rosen Penev <rosenp@gmail.com>

Committed... (tag: nfs-utils-2-4-4-rc3)

steved.
> ---
>  support/nfsidmap/libnfsidmap.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/support/nfsidmap/libnfsidmap.c b/support/nfsidmap/libnfsidmap.c
> index d11710f1..bce448cf 100644
> --- a/support/nfsidmap/libnfsidmap.c
> +++ b/support/nfsidmap/libnfsidmap.c
> @@ -89,6 +89,10 @@ gid_t nobody_gid = (gid_t)-1;
>  #define NFS4DNSTXTREC "_nfsv4idmapdomain"
>  #endif
>  
> +#ifndef NS_MAXMSG
> +#define NS_MAXMSG 65535
> +#endif
> +
>  /* Default logging fuction */
>  static void default_logger(const char *fmt, ...)
>  {
> 

