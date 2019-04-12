Return-Path: <SRS0=G8Mt=SO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9756C10F0E
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Apr 2019 05:57:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 81F1F2070D
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Apr 2019 05:57:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726217AbfDLF5P (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 12 Apr 2019 01:57:15 -0400
Received: from mail.bugwerft.de ([46.23.86.59]:53808 "EHLO mail.bugwerft.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725788AbfDLF5P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 Apr 2019 01:57:15 -0400
Received: from [192.168.178.170] (pD95EFA12.dip0.t-ipconnect.de [217.94.250.18])
        by mail.bugwerft.de (Postfix) with ESMTPSA id 9F9EA2A9DBE;
        Fri, 12 Apr 2019 05:55:32 +0000 (UTC)
Subject: Re: 5.1.0-rc4: Oops in __rpc_execute() when trying to boot from NFS
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Cc:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <0412f79c-61a8-bfa4-26ce-1083a59d31e8@zonque.org>
 <ce6d2388a9214f95cc38de5ec225cba26cf63b0d.camel@hammerspace.com>
 <4f4bb4a9-f752-f9f4-41cd-5c41d6191308@zonque.org>
 <7bdd83d7c2442d8096612ad3f821af556dd96015.camel@hammerspace.com>
 <78dbd13a-9a91-9a67-eaa6-ea7f0190898b@zonque.org>
 <be1368dce21d38bb1e90d2c84671ed51498d77ea.camel@hammerspace.com>
From:   Daniel Mack <daniel@zonque.org>
Openpgp: preference=signencrypt
Autocrypt: addr=daniel@zonque.org; prefer-encrypt=mutual; keydata=
 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
Message-ID: <d08ea2a9-080e-f039-35f3-ba6d388b1878@zonque.org>
Date:   Fri, 12 Apr 2019 07:57:11 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <be1368dce21d38bb1e90d2c84671ed51498d77ea.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

On 11/4/2019 9:50 PM, Trond Myklebust wrote:
> On Tue, 2019-04-09 at 19:54 +0200, Daniel Mack wrote:
>> On 9/4/2019 6:55 PM, Trond Myklebust wrote:
>>> On Tue, 2019-04-09 at 18:25 +0200, Daniel Mack wrote:
>>>> On 8/4/2019 8:51 PM, Trond Myklebust wrote:
>>>>> On Mon, 2019-04-08 at 19:01 +0200, Daniel Mack wrote:
>>>>>> Hi,
>>>>>>
>>>>>> I'm seeing the Oops below when trying to boot 5.1.0-rc4 on an
>>>>>> ARM
>>>>>> PXA3xx
>>>>>> platform. v5.0 did not show this effect with the same
>>>>>> cmdline.
>>>>>>
>>>>> Please do bisect if that is at all practical. I'm having
>>>>> trouble
>>>>> interpreting this Oops.
>>>>
>>>> Here you go:
>>>>
>>>> 009a82f6437490c262584d65a14094a818bcb747 is the first bad commit
>>>> commit 009a82f6437490c262584d65a14094a818bcb747
>>>> Author: Trond Myklebust <trond.myklebust@hammerspace.com>
>>>> Date:   Sat Mar 9 12:07:17 2019 -0500
>>>>
>>>>     SUNRPC: Micro-optimise when the task is known not to be
>>>> sleeping
>>>>
>>>>     In cases where we know the task is not sleeping, try to
>>>> optimise
>>>>     away the indirect call to task->tk_action() by replacing it
>>>> with
>>>>     a direct call.
>>>>     Only change tail calls, to allow gcc to perform tail call
>>>>     elimination.
>>>
>>> Ah... It looks like we explicitly turn off tail call optimisation
>>> in
>>> some ARM configs, so this might be a stack overflow.
>>>
>>> Does your config file have THUMB2_AVOID_R_ARM_THM_JUMP11 set?
>>
>> Nope. I don't even have THUMB2_KERNEL.
>>
>> In the meantime, I tried to trace that with some printks, but the bug
>> appears evasive, and the backtrace changes as soon as I modify the
>> timing. Hmm.
>>
>> Happy to test patches if you have any idea.
>>
> 
> Could you please try pulling the 'testing' branch from 
> http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=shortlog;h=refs/heads/testing
> 
> i.e. 'git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
> testing'
> 
> to see if that suffices to fix the issue you're reporting?

Yes, that revert in your branch fixes the problem. All fine again!


Thanks,
Daniel

