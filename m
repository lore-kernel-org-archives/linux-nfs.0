Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35363 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751385AbdGRRbs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jul 2017 13:31:48 -0400
Received: by mail-io0-f172.google.com with SMTP id k71so17268566iod.2
        for <linux-nfs@vger.kernel.org>; Tue, 18 Jul 2017 10:31:47 -0700 (PDT)
Subject: Re: [PATCH] nfs: count correct array for mnt3_counts array size
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@lst.de>
Cc: Eryu Guan <eguan@redhat.com>, linux-nfs@vger.kernel.org,
        Anna Schumaker <schumakeranna@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
References: <20170718053232.14858-1-eguan@redhat.com>
 <20170718090853.GA19665@lst.de> <20170718160444.GD19030@fieldses.org>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <212799c8-ae58-e5c9-2a65-f470cb9deeff@gmail.com>
Date: Tue, 18 Jul 2017 13:31:43 -0400
MIME-Version: 1.0
In-Reply-To: <20170718160444.GD19030@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/18/2017 12:04 PM, J. Bruce Fields wrote:
> On Tue, Jul 18, 2017 at 11:08:53AM +0200, Christoph Hellwig wrote:
>> On Tue, Jul 18, 2017 at 01:32:32PM +0800, Eryu Guan wrote:
>>> Array size of mnt3_counts should be the size of array
>>> mnt3_procedures, not mnt_procedures, though they're same in size
>>> right now. Found this by code inspection.
>>>
>>> Fixes: 1c5876ddbdb4 ("sunrpc: move p_count out of struct rpc_procinfo")
>>> Cc: Christoph Hellwig <hch@lst.de>
>>> Signed-off-by: Eryu Guan <eguan@redhat.com>
>>
>> Oops, yes.
>>
>> Looks good:
>>
>> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> Thanks, I'm assuming Anna gets this.

Yep, I'll take it.

> 
> --b.
> 
