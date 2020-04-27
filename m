Return-Path: <SRS0=uE3C=6L=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4B2EC54FD0
	for <linux-nfs@archiver.kernel.org>; Mon, 27 Apr 2020 14:14:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id AC040206B6
	for <linux-nfs@archiver.kernel.org>; Mon, 27 Apr 2020 14:14:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Dm7vS3H6"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727807AbgD0OOV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 27 Apr 2020 10:14:21 -0400
Received: from us-smtp-delivery-1.mimecast.com ([205.139.110.120]:40080 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1727022AbgD0OOU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2020 10:14:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1587996859;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=e3orOv4UV0UUot/Ua4Hzf+JbsqQyQDP5B+jzSFOMsFU=;
        b=Dm7vS3H6ixn4KSyTdXmu34DAWYAszmuSNJnqsxLpAGibDsksdyyC+u/L1f2ys5UR74jKaE
        MQFBAwRy7bS8AHeUuimoo6v/OeIWzimJiH/M//Yy5ZJvIXGWxB48KPTl2BoJzeaKgecoeE
        uaa0M5oYrOGDIeZNhdl3ZjGaF5Lv7Ao=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-128-76A4-QV6MRaMfWf3thZIPA-1; Mon, 27 Apr 2020 10:14:15 -0400
X-MC-Unique: 76A4-QV6MRaMfWf3thZIPA-1
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 1445818FE860;
        Mon, 27 Apr 2020 14:14:14 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-112-163.phx2.redhat.com [10.3.112.163])
        by smtp.corp.redhat.com (Postfix) with ESMTP id A493027CC9;
        Mon, 27 Apr 2020 14:14:13 +0000 (UTC)
Subject: Re: [Libtirpc-devel] [PATCH v2] pkg-config: use the correct
 replacements for libdir/includedir
To:     Eli Schwartz <eschwartz@archlinux.org>,
        libtirpc-devel@lists.sourceforge.net
Cc:     linux-nfs@vger.kernel.org
References: <20200419075201.1161001-1-eschwartz@archlinux.org>
 <20200420182635.1488536-1-eschwartz@archlinux.org>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <69f52eaf-52dd-9729-af35-a2c5f6a398b1@RedHat.com>
Date:   Mon, 27 Apr 2020 10:14:13 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
In-Reply-To: <20200420182635.1488536-1-eschwartz@archlinux.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 4/20/20 2:26 PM, Eli Schwartz wrote:
> They are defined pkg-config variables for a reason, let's reuse them as
> is the intended usage of pkg-config. This ensures various pkg-config
> features continue to work as expected.
> 
> Signed-off-by: Eli Schwartz <eschwartz@archlinux.org>
Committed... (tag: libtirpc-1-2-7-rc1)

steved.
> ---
> 
> v2: forgot the Libs change
> 
>  libtirpc.pc.in | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/libtirpc.pc.in b/libtirpc.pc.in
> index 38034c5..d2c7878 100644
> --- a/libtirpc.pc.in
> +++ b/libtirpc.pc.in
> @@ -7,6 +7,6 @@ Name: libtirpc
>  Description: Transport Independent RPC Library
>  Requires:
>  Version: @PACKAGE_VERSION@
> -Libs: -L@libdir@ -ltirpc
> +Libs: -L${libdir} -ltirpc
>  Libs.private: -lpthread
> -Cflags: -I@includedir@/tirpc
> +Cflags: -I${includedir}/tirpc
> 

