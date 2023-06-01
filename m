Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7867C77B7E
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Jun 2023 17:06:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231439AbjFARGe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Jun 2023 13:06:34 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48830 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229693AbjFARGe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jun 2023 13:06:34 -0400
Received: from forward501a.mail.yandex.net (forward501a.mail.yandex.net [178.154.239.81])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 73A4E194
        for <linux-nfs@vger.kernel.org>; Thu,  1 Jun 2023 10:06:32 -0700 (PDT)
Received: from mail-nwsmtp-smtp-production-main-18.vla.yp-c.yandex.net (mail-nwsmtp-smtp-production-main-18.vla.yp-c.yandex.net [IPv6:2a02:6b8:c1f:5f1d:0:640:49bf:0])
        by forward501a.mail.yandex.net (Yandex) with ESMTP id C7C945E93B;
        Thu,  1 Jun 2023 20:06:27 +0300 (MSK)
Received: by mail-nwsmtp-smtp-production-main-18.vla.yp-c.yandex.net (smtp/Yandex) with ESMTPSA id Q6SU323DfCg0-FLwfESvu;
        Thu, 01 Jun 2023 20:06:27 +0300
X-Yandex-Fwd: 1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex.ru; s=mail; t=1685639187;
        bh=FfEE42KSd8WyETy7bwVFiQSKZ1ePYYxii4Ubdrl6pgI=;
        h=Subject:From:In-Reply-To:Cc:Date:References:To:Message-ID;
        b=Zh0CIvcyaIdAHqZ21pQBWddkkUoHOUt2YCscl/yw6+0x19n4EURlDNDjUBa20xykt
         5JwYWH8huQDLDsGJ4kzCMngHlgy0sceB3OJLmhc2+I0jEVD5fUni1dyNWrP6OHsu79
         ULvto0zdepOBUvafUCEuDS2FtpKrgLXTB+I3oD7A=
Authentication-Results: mail-nwsmtp-smtp-production-main-18.vla.yp-c.yandex.net; dkim=pass header.i=@yandex.ru
Message-ID: <9fda7891-925a-1d9c-7c70-a7b040211199@yandex.ru>
Date:   Thu, 1 Jun 2023 20:06:26 +0300
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.10.0
Content-Language: en-US
To:     Dan Carpenter <dan.carpenter@linaro.org>
Cc:     Chuck Lever III <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>, Tom Rix <trix@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20230601143332.255312-1-dmantipov@yandex.ru>
 <2D3D2D8E-4E7A-4B50-A1FF-486D7F6C26D4@oracle.com>
 <8ed6eb2b-fdfa-4fde-81f3-92e6b34bc509@kadam.mountain>
 <ed2f956d-632a-90e1-f2e9-91710be5f2de@yandex.ru>
 <c6c5c38b-f258-4dda-8227-5f672b37bc77@kadam.mountain>
From:   Dmitry Antipov <dmantipov@yandex.ru>
Subject: Re: [PATCH] sunrpc: fix clang-17 warning
In-Reply-To: <c6c5c38b-f258-4dda-8227-5f672b37bc77@kadam.mountain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 6/1/23 19:39, Dan Carpenter wrote:

> It's a false positive because the test is obviously intended for 32-bit
> longs.

I'm not an expert in compiler development, but I do not understand
"obviously intended" in this context. An input literally compares
<any unsigned 32-bit> > <max unsigned 64-bit> / 8, which is always
false, and so the compiler complains. If "obviously intended" means
"the compiler should silently optimize away this check for LP64",
I would disagree, and that's why I would like to see the confirmation
from LLVM/clang developers.

Dmitry

