Return-Path: <SRS0=nmVN=6E=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43B02C38A30
	for <linux-nfs@archiver.kernel.org>; Mon, 20 Apr 2020 17:47:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 19DAB21D79
	for <linux-nfs@archiver.kernel.org>; Mon, 20 Apr 2020 17:47:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="JsWnnyMd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726021AbgDTRru (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 20 Apr 2020 13:47:50 -0400
Received: from us-smtp-delivery-1.mimecast.com ([207.211.31.120]:32942 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1725784AbgDTRru (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Apr 2020 13:47:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1587404869;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=fAbdrnSsZiMwRohf9t9VUJ1O2oEoN0nmu326tsKjYJw=;
        b=JsWnnyMdakhsvuPiQpWEO86VWx876+cb/wEScRWxnIIb1B9y0O7Hr8AUokLu+qRJvflQ8C
        3y16s5lNbAIrMYTZIOlYkuBfw0iAcS4/KjRbQ+DPzZNiiYrAz0JUBlA2KiQItUaGVxPTSN
        8tmbaxfzyPFMVjaOlf1CKq80wjckXqE=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-209-QPuM02_6PimGiqRN-bVQuw-1; Mon, 20 Apr 2020 13:47:46 -0400
X-MC-Unique: QPuM02_6PimGiqRN-bVQuw-1
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 5D7391005509;
        Mon, 20 Apr 2020 17:47:45 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-112-47.phx2.redhat.com [10.3.112.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id BACE819C4F;
        Mon, 20 Apr 2020 17:47:44 +0000 (UTC)
Subject: Re: [Libtirpc-devel] [PATCH] pkg-config: use the correct replacements
 for libdir/includedir
To:     Eli Schwartz <eschwartz@archlinux.org>,
        libtirpc-devel@lists.sourceforge.net
Cc:     linux-nfs@vger.kernel.org
References: <20200419075201.1161001-1-eschwartz@archlinux.org>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <3c90187c-8b02-9d74-3890-63dd36c2c56f@RedHat.com>
Date:   Mon, 20 Apr 2020 13:47:44 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
In-Reply-To: <20200419075201.1161001-1-eschwartz@archlinux.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

On 4/19/20 3:52 AM, Eli Schwartz wrote:
> They are defined pkg-config variables for a reason, let's reuse them as
> is the intended usage of pkg-config. This ensures various pkg-config
> features continue to work as expected.
Just curious... What pkg-config feature does this fix?

steved.

> 
> Signed-off-by: Eli Schwartz <eschwartz@archlinux.org>
> ---
>  libtirpc.pc.in | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/libtirpc.pc.in b/libtirpc.pc.in
> index 38034c5..863950f 100644
> --- a/libtirpc.pc.in
> +++ b/libtirpc.pc.in
> @@ -9,4 +9,4 @@ Requires:
>  Version: @PACKAGE_VERSION@
>  Libs: -L@libdir@ -ltirpc
>  Libs.private: -lpthread
> -Cflags: -I@includedir@/tirpc
> +Cflags: -I${includedir}/tirpc
> 

