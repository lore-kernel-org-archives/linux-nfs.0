Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33991 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754973AbbI0HEU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2015 03:04:20 -0400
Received: by wicfx3 with SMTP id fx3so66835104wic.1
        for <linux-nfs@vger.kernel.org>; Sun, 27 Sep 2015 00:03:59 -0700 (PDT)
Subject: Re: [PATCH v2 15/26] IB/srp: Split srp_map_sg
To: Bart Van Assche <bart.vanassche@sandisk.com>,
        Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
 <1443116118-10730-16-git-send-email-sagig@mellanox.com>
 <56057320.4010905@sandisk.com>
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <560794DB.1050200@dev.mellanox.co.il>
Date: Sun, 27 Sep 2015 10:03:55 +0300
MIME-Version: 1.0
In-Reply-To: <56057320.4010905@sandisk.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/25/2015 7:15 PM, Bart Van Assche wrote:
> On 09/24/2015 10:35 AM, Sagi Grimberg wrote:
>> This is a perparation patch for the new registration API
>              ^ preparation ?

Fixed, thanks.

>> +    WARN_ON_ONCE(!dev->use_fmr);
>> +
>> +    if (state->npages == 0)
>> +        return 0;
>> +
>> +    if (state->npages == 1 && target->global_mr) {
>> +        srp_map_desc(state, state->base_dma_addr, state->dma_len,
>> +                 target->global_mr->rkey);
>> +        return 0;
>> +    }
>> +
>
> The above is not correct. The npages and dma_len variables have to be
> reset before returning. How about changing the "return 0" statement into
> "goto reset_state" and adding a "reset_state" label ?

Done, thanks.
