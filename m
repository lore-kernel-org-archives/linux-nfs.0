Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33295 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbbJJBGd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2015 21:06:33 -0400
Received: by wiclk2 with SMTP id lk2so90739956wic.0
        for <linux-nfs@vger.kernel.org>; Fri, 09 Oct 2015 18:06:32 -0700 (PDT)
Subject: Re: [PATCH v3 12/26] xprtrdma: Port to new memory registration API
To: Chuck Lever <chuck.lever@oracle.com>, Sagi Grimberg <sagig@mellanox.com>
References: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
 <1444290669-5252-13-git-send-email-sagig@mellanox.com>
 <87F3CC02-2979-4C6B-990A-C31C52790ABC@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56186495.6060309@dev.mellanox.co.il>
Date: Sat, 10 Oct 2015 04:06:29 +0300
MIME-Version: 1.0
In-Reply-To: <87F3CC02-2979-4C6B-990A-C31C52790ABC@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> out_list_err:
>> -	rc = PTR_ERR(f->fr_pgl);
>> +	rc = -ENOMEM;
>> 	dprintk("RPC:       %s: ib_alloc_fast_reg_page_list status %i\n”,
>
> Should you update this debugging message?

Yes I will.

>> +	n = ib_map_mr_sg(mr, frmr->sg, frmr->sg_nents, PAGE_SIZE);
>> +	if (unlikely(n != frmr->sg_nents)) {
>
> The basic logic looks OK. But signed v. unsigned comparison here?
> Is there a guarantee that the maximum value sg_nents can have is
> INT_MAX?
>
> i and n are signed, sg_nents is unsigned. I’d prefer to have
> the variable signage all agree. Since we’re counting stuff,
> maybe unsigned all around is a better choice? (rc should
> remain signed).

OK, I'll make i, n, len unsigned integers.

>
> If ib_map_mr_sg can return a negative value, maybe “rc = ib_map_mr_sg”
> is more clear. Is n used anywhere else?

Nop.

>
> Use %u formatter for displaying unsigned variables.
>
>
>> +		pr_err("RPC:       %s: failed to map mr %p (%d/%d)\n",
>> +		       __func__, frmr->fr_mr, n, frmr->sg_nents);
>> +		rc = n < 0 ? n : -EINVAL;
>> +		goto out_senderr;
>
> Is frmr->sg_nents set correctly here for the ib_dma_unmap_sg()
> call in the error exit? Maybe you want to use the value in
> “n” instead (as long as it’s positive, of course).

Umm, I think that frmr->sg_nents is assigned before the unmap is even
reachable (we assign before mapping because we won't take partial
maapings at least for now).



I'll be waiting for more comments before posting v4.

Cheers,
Sagi.
