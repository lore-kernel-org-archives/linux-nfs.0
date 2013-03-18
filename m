Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:44263 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431Ab3CRREc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Mar 2013 13:04:32 -0400
Received: by mail-vc0-f174.google.com with SMTP id hx10so3097509vcb.5
        for <linux-nfs@vger.kernel.org>; Mon, 18 Mar 2013 10:04:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51473F46.10401@tonian.com>
References: <1363617532-24172-1-git-send-email-bhalevy@tonian.com>
	<1363622128.4351.15.camel@leira.trondhjem.org>
	<51473F46.10401@tonian.com>
Date: Mon, 18 Mar 2013 13:04:31 -0400
Message-ID: <CADnza476e0FpXJJfE8OmXLRQUR3Zm_aZkX7JZRB=vGyZ-U2yDg@mail.gmail.com>
Subject: Re: [PATCH] pnfs: do not reset to mds if wb_offset != wb_pgbase
From: Fred Isaman <faisaman4@gmail.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "stable@kernel.org" <stable@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 18, 2013 at 12:22 PM, Benny Halevy <bhalevy@tonian.com> wrote:

>> NACK. I see no evidence that we've addressed the issues that were raised
>> by Fred in commit 1825a0d08f22463e5a8f4b1636473efd057a3479 (NFS: prepare
>> coalesce testing for directio).
>> If you think that his concerns about the coalescing assumptions are no
>> longer true, then please point to why this is the case. AFAICR that
>> patch was added to fix corruption issues.
>>
>
> We see no problems with this patch with the workloads we're testing.
> Do you have a test that reproduces the original problem that we can try running?
>
> Benny

A problem case is if the layout ends within the page request, which
can happen due to the misalignment.

Fred
