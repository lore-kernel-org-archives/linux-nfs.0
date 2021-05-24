Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C429C04FF3
	for <linux-nfs@archiver.kernel.org>; Mon, 24 May 2021 14:44:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1CCCF613B0
	for <linux-nfs@archiver.kernel.org>; Mon, 24 May 2021 14:44:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233048AbhEXOpj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 May 2021 10:45:39 -0400
Received: from bronze1.eecs.yorku.ca ([130.63.94.75]:51284 "EHLO
        bronze1.eecs.yorku.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233045AbhEXOph (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2021 10:45:37 -0400
Received: from [170.133.224.154] (helo=[192.168.1.136])
        by bronze1.eecs.yorku.ca with esmtpsa  (TLS1.2) tls TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
        (Exim 4.94.2-31-503e55a2c)
        (envelope-from <jas@eecs.yorku.ca>)
        id 1llBoO-0012Sp-BD; Mon, 24 May 2021 10:44:08 -0400
Subject: Re: ksu problem with sec=krb5 and nfs
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     linux-nfs@vger.kernel.org
References: <abbd93ac-4a68-a471-fbb4-a9baf05b89c9@eecs.yorku.ca>
 <7714ABF4-E9CD-424B-BF7F-6F1B91F58C2B@redhat.com>
From:   Jason Keltz <jas@eecs.yorku.ca>
Message-ID: <dd51738b-b2c2-2dcf-68b1-e78c66d08b28@eecs.yorku.ca>
Date:   Mon, 24 May 2021 10:44:01 -0400
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/20100101
 Thunderbird/78.10.1
MIME-Version: 1.0
In-Reply-To: <7714ABF4-E9CD-424B-BF7F-6F1B91F58C2B@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Benjamin,

That's exactly it - I definately want ksu to be writing that exact 
file.  Any idea why it isn't, and why it matters if the home directory 
is using sec=krb5 or not?

Jason.

On 5/24/2021 7:30 AM, Benjamin Coddington wrote:
> On 22 May 2021, at 10:47, Jason Keltz wrote:
>
>> Can someone help me understand the issue, and whether there is a solution?
> Don't you want ksu to write its target cache to /tmp/krb5cc_1011 so rpc.gssd
> can find it?  Why isn't that happening?
>
> Ben
>
>
