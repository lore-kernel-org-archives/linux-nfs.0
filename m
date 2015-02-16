Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f50.google.com ([74.125.82.50]:48732 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183AbbBPNYw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Feb 2015 08:24:52 -0500
Received: by mail-wg0-f50.google.com with SMTP id l2so29351684wgh.9
        for <linux-nfs@vger.kernel.org>; Mon, 16 Feb 2015 05:24:51 -0800 (PST)
Message-ID: <54E17F18.8070809@linaro.org>
Date: Mon, 16 Feb 2015 05:24:40 +0000
From: Daniel Thompson <daniel.thompson@linaro.org>
MIME-Version: 1.0
To: Arnd Bergmann <arnd@arndb.de>, linaro-kernel@lists.linaro.org
CC: Christoph Hellwig <hch@lst.de>, patches@linaro.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: Fix v2-only build regression
References: <1424086563-25570-1-git-send-email-daniel.thompson@linaro.org> <2435499.xPpCe4zRXk@wuerfel>
In-Reply-To: <2435499.xPpCe4zRXk@wuerfel>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 16/02/15 11:54, Arnd Bergmann wrote:
> On Monday 16 February 2015 11:36:03 Daniel Thompson wrote:
>> Currently if nfsd is configured as v2 only then the kernel fails to build.
>> This is a regression introduced by 9cf514ccfacb("nfsd: implement pNFS
>> operations"). It occurs because inline code from the xdr4.h header is
>> now included from generic nfsd code (via pnfs.h).
>>
>> This patch takes the simplest route and makes conditional the problematic
>> inline function.
>>
>> Note: I also tried extending the #ifdef CONFIG_NFSD_PNFS to cover almost
>>       all of the pnfs.h header file. That works great too but feels more
>>       invasive. However I can dust this off if that were preferable for
>>       any reason.
>>
> 
> I believe this was fixed last Friday in the patch below. Do you still
> see the problem on today's linux-next?

Thanks Arnd. I overlooked this patch (which didn't pop out very clearly
in the google searches I did).

It is fixed in linux-next.


Daniel.

