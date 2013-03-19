Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f177.google.com ([209.85.215.177]:42753 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932918Ab3CSTfo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 15:35:44 -0400
Received: by mail-ea0-f177.google.com with SMTP id r16so415438ead.8
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 12:35:42 -0700 (PDT)
Message-ID: <5148BE0B.9080802@tonian.com>
Date: Tue, 19 Mar 2013 21:35:39 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Fred Isaman <faisaman4@gmail.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "stable@kernel.org" <stable@kernel.org>
Subject: Re: [PATCH] pnfs: do not reset to mds if wb_offset != wb_pgbase
References: <1363617532-24172-1-git-send-email-bhalevy@tonian.com> <1363622128.4351.15.camel@leira.trondhjem.org> <51473F46.10401@tonian.com> <CADnza476e0FpXJJfE8OmXLRQUR3Zm_aZkX7JZRB=vGyZ-U2yDg@mail.gmail.com>
In-Reply-To: <CADnza476e0FpXJJfE8OmXLRQUR3Zm_aZkX7JZRB=vGyZ-U2yDg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-18 19:04, Fred Isaman wrote:
> On Mon, Mar 18, 2013 at 12:22 PM, Benny Halevy <bhalevy@tonian.com> wrote:
> 
>>> NACK. I see no evidence that we've addressed the issues that were raised
>>> by Fred in commit 1825a0d08f22463e5a8f4b1636473efd057a3479 (NFS: prepare
>>> coalesce testing for directio).
>>> If you think that his concerns about the coalescing assumptions are no
>>> longer true, then please point to why this is the case. AFAICR that
>>> patch was added to fix corruption issues.
>>>
>>
>> We see no problems with this patch with the workloads we're testing.
>> Do you have a test that reproduces the original problem that we can try running?
>>
>> Benny
> 
> A problem case is if the layout ends within the page request, which
> can happen due to the misalignment.

First, the file layout currently supports only whole file layouts so I don't see
how that's a problem.
Regardless, I'd rather trim the layout segment to PAGE_SIZE boundaries
and get a new layout from the page aligned offset and on with minlength = PAGE_SIZE
(as we do today).

Benny

> 
> Fred
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
