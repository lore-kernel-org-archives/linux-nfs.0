Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f171.google.com ([74.125.82.171]:46575 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822Ab3C0MTG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Mar 2013 08:19:06 -0400
Received: by mail-we0-f171.google.com with SMTP id d46so5428046wer.16
        for <linux-nfs@vger.kernel.org>; Wed, 27 Mar 2013 05:19:04 -0700 (PDT)
Message-ID: <5152E3B5.8080402@tonian.com>
Date: Wed, 27 Mar 2013 14:19:01 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Fred Isaman <faisaman4@gmail.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs: do not reset to mds if wb_offset != wb_pgbase
References: <1363617532-24172-1-git-send-email-bhalevy@tonian.com> <1363622128.4351.15.camel@leira.trondhjem.org> <51473F46.10401@tonian.com> <CADnza476e0FpXJJfE8OmXLRQUR3Zm_aZkX7JZRB=vGyZ-U2yDg@mail.gmail.com> <5148BE0B.9080802@tonian.com> <CADnza46Npnn=GquO8s7TPPSGZq9Cs11JJdj6t8ejDh5gYeeTYg@mail.gmail.com>
In-Reply-To: <CADnza46Npnn=GquO8s7TPPSGZq9Cs11JJdj6t8ejDh5gYeeTYg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-19 22:28, Fred Isaman wrote:
> On Tue, Mar 19, 2013 at 3:35 PM, Benny Halevy <bhalevy@tonian.com> wrote:
>> On 2013-03-18 19:04, Fred Isaman wrote:
>>> A problem case is if the layout ends within the page request, which
>>> can happen due to the misalignment.
>>
>> First, the file layout currently supports only whole file layouts so I don't see
>> how that's a problem.
>> Regardless, I'd rather trim the layout segment to PAGE_SIZE boundaries
>> and get a new layout from the page aligned offset and on with minlength = PAGE_SIZE
>> (as we do today).
>>
>> Benny
>>
> 
> Yes, but consider....
> 
> let P = PAGE_SIZE
> 
> assume you have a layout from 0 to 4P, and you try to do a WRITE from
> 2P to 6P.  Now if the buffer is not page aligned, one of the nfs_page
> requests will contain the file's logical 4P offset at a random
> location within the nfs_page.  What happens then?

Fred,  Can you please provide a test that reproduces this concern
so we can verify the system behavior with and without my patch?

Benny

> 
> Fred
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
