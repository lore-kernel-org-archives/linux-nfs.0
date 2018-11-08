Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B900C32789
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 05:08:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E8E4320857
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 05:08:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8E4320857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=candelatech.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728805AbeKHOmD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 09:42:03 -0500
Received: from mail2.candelatech.com ([208.74.158.173]:44722 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728499AbeKHOmD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Nov 2018 09:42:03 -0500
Received: from [192.168.1.47] (unknown [50.34.223.145])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id 2831940A5A2;
        Wed,  7 Nov 2018 21:08:18 -0800 (PST)
Subject: Re: Support for VRF in NFS?
To:     "J. Bruce Fields" <bfields@fieldses.org>
References: <b608aeda-358d-18c9-ebcd-753b698580e9@candelatech.com>
 <20181108011429.GC30776@fieldses.org>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From:   Ben Greear <greearb@candelatech.com>
Message-ID: <efe334ad-4905-fc24-1b36-3c4129b72888@candelatech.com>
Date:   Wed, 7 Nov 2018 21:08:16 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101
 Thunderbird/45.8.0
MIME-Version: 1.0
In-Reply-To: <20181108011429.GC30776@fieldses.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 11/07/2018 05:14 PM, J. Bruce Fields wrote:
> On Tue, Nov 06, 2018 at 01:03:54PM -0800, Ben Greear wrote:
>> Hello,
>>
>> I made a stab at implementing VRF support in NFS, but it appears
>> fairly complicated and I ended up reverting my changes....
>>
>> Is anyone working on this?
>>
>> And, if not, if anyone would like to be sponsored to work on this, please
>> let me know.
>
> Um, sorry--what's VRF?

Virtual Router logic.  It is sort of like network stack containers,
and has been solid and fully featured in the kernel since 4.16 or so.

In the end, you effectively need to call the logic that SO_BINDTODEVICE
calls on the socket before binding to an IP.

The NFS and RPC logic is a giant tangled mess to my eyes, so
hoping I could bribe someone else to do it :)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
