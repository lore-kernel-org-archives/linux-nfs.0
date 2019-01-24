Return-Path: <SRS0=k36n=QA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B1C6C282C3
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 12:29:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3A6D82184B
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 12:29:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727443AbfAXM3j (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Jan 2019 07:29:39 -0500
Received: from szxga04-in.huawei.com ([45.249.212.190]:2227 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727386AbfAXM3j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Jan 2019 07:29:39 -0500
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id 11257C746CD077B3C1B2;
        Thu, 24 Jan 2019 20:29:37 +0800 (CST)
Received: from [127.0.0.1] (10.184.189.120) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.408.0; Thu, 24 Jan 2019
 20:29:34 +0800
Subject: Re: [PATCH] lockd: NSMPROC_MON should be send only once even if in
 multithread
To:     Chuck Lever <chucklever@gmail.com>
CC:     Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <1547705746-69554-1-git-send-email-zhangxiaoxu5@huawei.com>
 <4E812155-4DB4-4EF4-91ED-EDBB1B0BBFF7@gmail.com>
 <00390d85-d2dd-be57-4192-bff562a75684@huawei.com>
 <E87ADB64-FE89-48A8-A401-3153E029D0DA@gmail.com>
From:   "zhangxiaoxu (A)" <zhangxiaoxu5@huawei.com>
Message-ID: <bdef1ea6-1b71-a638-7274-d2109db5e1d1@huawei.com>
Date:   Thu, 24 Jan 2019 20:29:18 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.0
MIME-Version: 1.0
In-Reply-To: <E87ADB64-FE89-48A8-A401-3153E029D0DA@gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.189.120]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 1/19/2019 4:59 AM, Chuck Lever wrote:
> 
> 
>> On Jan 17, 2019, at 9:48 PM, zhangxiaoxu (A) <zhangxiaoxu5@huawei.com> wrote:
>>
>>
>>
>> On 1/17/2019 10:33 PM, Chuck Lever wrote:
>>> Hi, what is the harm of sending more than one MON request for a peer?
>> Maybe no harm.
>> The rpc.statd won't record the peer twice.
>>
>> I found this when I tested the xfstest generic/089.
>> The rpc task for that msg sometimes take very long time.
>> rpc took 57 sec who t_mtab/2377 srv rpc.statd xid 2453489031 prog statd/100024/1 proc 2 prot 6 flags 0x680
> 
> MON is supposed to be a call to a local service (on the same host).
> It would be interesting if you could determine why it takes so long.
> 
Yes, I'm working for that.
I think this is an optimization point.
Why do we have to send multiple requests?
> 
>> I think the msg just send only one time is enough.
>> RPC and rpc.statd maybe consume for a long time on the network.
> 
> 
> --
> Chuck Lever
> chucklever@gmail.com
> 
> 
> 
> 
> 

