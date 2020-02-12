Return-Path: <SRS0=GDzj=4A=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 863F6C35242
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Feb 2020 00:16:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 63484206D6
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Feb 2020 00:16:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728043AbgBLAQi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Feb 2020 19:16:38 -0500
Received: from mail1.ugh.no ([178.79.162.34]:46522 "EHLO mail1.ugh.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728025AbgBLAQi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Feb 2020 19:16:38 -0500
Received: from localhost (localhost [127.0.0.1])
        by mail1.ugh.no (Postfix) with ESMTP id 987DF24EA99;
        Wed, 12 Feb 2020 01:16:36 +0100 (CET)
Received: from mail1.ugh.no ([127.0.0.1])
        by localhost (catastrophix.ugh.no [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id 8BqjRa5j_czg; Wed, 12 Feb 2020 01:16:35 +0100 (CET)
Received: from [10.255.64.11] (unknown [185.176.245.143])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: andre@tomt.net)
        by mail.ugh.no (Postfix) with ESMTPSA id 7E26F24EA64;
        Wed, 12 Feb 2020 01:16:35 +0100 (CET)
Subject: Re: [PATCH v1] xprtrdma: Fix DMA scatter-gather list mapping
 imbalance
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     robin.murphy@arm.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        iommu@lists.linux-foundation.org
References: <158145102079.515252.3226617475691911684.stgit@morisot.1015granger.net>
 <8781b043-74a6-4ee0-d1c9-46f797b4aec2@tomt.net>
 <DC2EEB01-5C19-4FB5-B103-D9ADF09E07FA@oracle.com>
From:   Andre Tomt <andre@tomt.net>
Message-ID: <a8789f8a-9574-b032-3f6c-8d2d2ee74b34@tomt.net>
Date:   Wed, 12 Feb 2020 01:16:35 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.4.1
MIME-Version: 1.0
In-Reply-To: <DC2EEB01-5C19-4FB5-B103-D9ADF09E07FA@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 11.02.2020 23:00, Chuck Lever wrote:
> Hi Andre, thanks for trying this out.
> 
>> On Feb 11, 2020, at 3:50 PM, Andre Tomt <andre@tomt.net> wrote:
>>
>> On 11.02.2020 20:58, Chuck Lever wrote:
>>> The @nents value that was passed to ib_dma_map_sg() has to be passed
>>> to the matching ib_dma_unmap_sg() call. If ib_dma_map_sg() choses to
>>> concatenate sg entries, it will return a different nents value than
>>> it was passed.
>>> The bug was exposed by recent changes to the AMD IOMMU driver.
>>
>> This seems to fail differently on my system; mount fails with:
>> mount.nfs: mount system call failed
>>
>> and the kernel log reports:
>> [   38.890344] NFS: Registering the id_resolver key type
>> [   38.890351] Key type id_resolver registered
>> [   38.890352] Key type id_legacy registered
>> [   38.901799] NFS: nfs4_discover_server_trunking unhandled error -5. Exiting with error EIO
>> [   38.901817] NFS4: Couldn't follow remote path
>>
>> amd_iommu=off still works
>>
>> One detail I accidentally left out of the original report is that the server (intel system) is running Ubuntu 20.04 ("beta") userspace, and AMD clients are Ubuntu 19.10 userspace. Although I dont believe this to matter at this point.
> 
> Next thing to try:
> 
> # trace-cmd record -e sunrpc -e rpcrdma
> 
> then issue the mount command. Once it completes, ^C the trace-cmd and send me trace.dat.
> 
> Try this with both the v5.4 kernel and the v5.5 kernel (and note that trace-cmd overwrites trace.dat, so copy it out between tests).

I've uploaded them to https://tomt.net/temp/rdmaiommubug/
I'll probably do a 5.5.3 with the v1 fix as well, should show up 
momentarily.

>>> Reported-by: Andre Tomt <andre@tomt.net>
>>> Suggested-by: Robin Murphy <robin.murphy@arm.com>
>>> Fixes: 1f541895dae9 ("xprtrdma: Don't defer MR recovery if ro_map fails")
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>   net/sunrpc/xprtrdma/frwr_ops.c |    5 ++---
>>>   1 file changed, 2 insertions(+), 3 deletions(-)
>>> Hey Andre, please try this out. It just reverts the bit of brokenness that
>>> Robin observed this morning. I've done basic testing here with Intel
>>> IOMMU systems, no change in behavior (ie, all good to go).
>>> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
>>> index 095be887753e..449bb51e4fe8 100644
>>> --- a/net/sunrpc/xprtrdma/frwr_ops.c
>>> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
>>> @@ -313,10 +313,9 @@ struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
>>>   			break;
>>>   	}
>>>   	mr->mr_dir = rpcrdma_data_dir(writing);
>>> +	mr->mr_nents = i;
>>>   -	mr->mr_nents =
>>> -		ib_dma_map_sg(ia->ri_id->device, mr->mr_sg, i, mr->mr_dir);
>>> -	if (!mr->mr_nents)
>>> +	if (!ib_dma_map_sg(ia->ri_id->device, mr->mr_sg, i, mr->mr_dir))
>>>   		goto out_dmamap_err;
>>>     	ibmr = mr->frwr.fr_mr;
>>
> 
> --
> Chuck Lever
> 
> 
> 

