Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78FF1C4167B
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Nov 2023 14:43:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231602AbjKAOnM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 1 Nov 2023 10:43:12 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43102 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229800AbjKAOnL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Nov 2023 10:43:11 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2141083
        for <linux-nfs@vger.kernel.org>; Wed,  1 Nov 2023 07:42:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1698849742;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=xrKV/FcGLWmVkEqAFFeYCF9Q0Cekz/Ho75bnIsa9SYU=;
        b=ZH9/t1WjlpqZSribkAyoVpe1+FFpFWzEw8rCkNuNXhJxEpuqVhM7gFbTiVdRru5YVQvWpz
        eT1UI4Kx0pPT1i/Yq+1mSTHf09K0qrgOZIBuC6BS4gqHGesh/qBA8b3vy1cOZN3LR3zF8w
        mfaY74I/1pmHN0QteRFWbNXm33Iad5w=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-608-4NYTZUpPOUmUzyyVsrbWZQ-1; Wed, 01 Nov 2023 10:42:17 -0400
X-MC-Unique: 4NYTZUpPOUmUzyyVsrbWZQ-1
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.rdu2.redhat.com [10.11.54.1])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 58CE781D87E;
        Wed,  1 Nov 2023 14:42:17 +0000 (UTC)
Received: from [192.168.37.1] (unknown [10.22.50.5])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id DB44325C0;
        Wed,  1 Nov 2023 14:42:16 +0000 (UTC)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     Martin Wege <martin.l.wege@gmail.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 referrals - custom (non-2049) port numbers in fs_locations?
Date:   Wed, 01 Nov 2023 10:42:15 -0400
Message-ID: <DD47B60A-E188-49BC-9254-6C032BA9776E@redhat.com>
In-Reply-To: <CANH4o6Md0+56y0ZYtNj1ViF2WGYqusCmjOB6mLeu+nOtC5DPTw@mail.gmail.com>
References: <CANH4o6Md0+56y0ZYtNj1ViF2WGYqusCmjOB6mLeu+nOtC5DPTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 3.4.1 on 10.11.54.1
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 1 Nov 2023, at 5:06, Martin Wege wrote:

> Good morning!
>
> We have questions about NFSv4 referrals:
> 1. Is there a way to test them in Debian Linux?
>
> 2. How does a fs_locations attribute look like when a nonstandard port
> like 6666 is used?
> RFC5661 says this:
>
> * http://tools.ietf.org/html/rfc5661#section-11.9
> * 11.9. The Attribute fs_locations
> * An entry in the server array is a UTF-8 string and represents one of a
> * traditional DNS host name, IPv4 address, IPv6 address, or a zero-length
> * string.  An IPv4 or IPv6 address is represented as a universal address
> * (see Section 3.3.9 and [15]), minus the netid, and either with or without
> * the trailing ".p1.p2" suffix that represents the port number.  If the
> * suffix is omitted, then the default port, 2049, SHOULD be assumed.  A
> * zero-length string SHOULD be used to indicate the current address being
> * used for the RPC call.
>
> Does anyone have an example of how the content of fs_locations should
> look like with a custom port number?

If you keep following the references, you end up with the example in
rfc5665, which gives an example for IPv4:

https://datatracker.ietf.org/doc/html/rfc5665#section-5.2.3.3

Ben

