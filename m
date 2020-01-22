Return-Path: <SRS0=bKkf=3L=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E67CC2D0DB
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jan 2020 18:11:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E56952465A
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jan 2020 18:11:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=aruba.it header.i=@aruba.it header.b="Ykhz+uew"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725933AbgAVSLE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Jan 2020 13:11:04 -0500
Received: from smtpcmd13146.aruba.it ([62.149.156.146]:39816 "EHLO
        smtpcmd13146.aruba.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725802AbgAVSLE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jan 2020 13:11:04 -0500
Received: from [192.168.126.128] ([146.241.70.103])
        by smtpcmd13.ad.aruba.it with bizsmtp
        id tWB12100L2DhmGq01WB18z; Wed, 22 Jan 2020 19:11:02 +0100
Subject: Re: [nfs-utils PATCH] locktest: Makefile.am: remove host compiler
 costraint
To:     Steve Dickson <SteveD@RedHat.com>, linux-nfs@vger.kernel.org
References: <20200115160806.99991-1-giulio.benetti@benettiengineering.com>
 <ae36c91f-bed4-3839-bdd5-fffdcca9bf40@RedHat.com>
From:   Giulio Benetti <giulio.benetti@benettiengineering.com>
Message-ID: <92111fa0-a808-84da-19b8-823ad6a26a99@benettiengineering.com>
Date:   Wed, 22 Jan 2020 19:11:01 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.4.1
MIME-Version: 1.0
In-Reply-To: <ae36c91f-bed4-3839-bdd5-fffdcca9bf40@RedHat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=aruba.it; s=a1;
        t=1579716662; bh=XuzferKvhJRQbdzX/ZyncMRiKDGd/asKgcs1DeSTtQU=;
        h=Subject:To:From:Date:MIME-Version:Content-Type;
        b=Ykhz+uewnewj7iLuKhz3ojAnvHzO0DsFHlmM2IJq4NsZSNAhaUg1DaiA+gioJHTtb
         +kl0ZXvOkWcot8lIiRxyaB2pWIJV04hIu4FxFnaLyhGsoZ2qKPDXzJ9cSUAWU0ZORw
         ZE6SPfctHZ/4yUOMc37i43xA+p8MVn2d2XlzLCFPwzGwMjhh3c7tCTS9u8ZzVn5n/O
         /V40sJAOxiRQJTt/zgZ3GKKNGx+5gx3+Bde8ZNVelf/EqNyl6HRBvtVqcZgW2eg/oi
         ogFuh51/YTaGZVRFMVksP5we/7jl4LGTnhwrZlFZt4MAQT6RHRmH8IB2mF/f8RuzjE
         3PfbziF/+AfHA==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Steve,

On 1/22/20 6:56 PM, Steve Dickson wrote:
> 
> 
> On 1/15/20 11:08 AM, Giulio Benetti wrote:
>> Currently locktest can be built only for host because CC_FOR_BUILD is
>> specified as CC, but this leads to build failure when passing CFLAGS not
>> available on host gcc(i.e. -mlongcalls) and most of all locktest would
>> be available on target systems the same way as rpcgen etc. So remove CC
>> and LIBTOOL assignments.
>>
>> Signed-off-by: Giulio Benetti <giulio.benetti@benettiengineering.com>
> Committed... (tag: nfs-utils-2-4-3-rc6)

I've just setup up a Gentoo to try building nfs-utils, I give a try 
anyway by now, so we should be sure.

Best regards
-- 
Giulio Benetti
Benetti Engineering sas

> steved.
>> ---
>>   tools/locktest/Makefile.am | 3 ---
>>   1 file changed, 3 deletions(-)
>>
>> diff --git a/tools/locktest/Makefile.am b/tools/locktest/Makefile.am
>> index 3156815d..e8914655 100644
>> --- a/tools/locktest/Makefile.am
>> +++ b/tools/locktest/Makefile.am
>> @@ -1,8 +1,5 @@
>>   ## Process this file with automake to produce Makefile.in
>>   
>> -CC=$(CC_FOR_BUILD)
>> -LIBTOOL = @LIBTOOL@ --tag=CC
>> -
>>   noinst_PROGRAMS = testlk
>>   testlk_SOURCES = testlk.c
>>   testlk_CFLAGS=$(CFLAGS_FOR_BUILD)
>>
> 

