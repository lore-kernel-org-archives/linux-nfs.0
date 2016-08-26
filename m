Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:15135 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751559AbcHZUgQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 Aug 2016 16:36:16 -0400
Subject: Re: [PATCH v4 0/3] NFSv4.2: Add support for the COPY operation
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <1461962533-26534-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20160501173733.GA556@infradead.org> <20160513203135.GE5658@fieldses.org>
 <8d09611c-31c1-baca-8e8f-6dc599731c8c@Netapp.com>
 <20160729185933.GA7964@fieldses.org>
 <613202c0-68ed-2ec0-2de9-136003309cb5@Netapp.com>
 <20160729202024.GD7964@fieldses.org>
CC: Christoph Hellwig <hch@infradead.org>, <linux-nfs@vger.kernel.org>,
        <Trond.Myklebust@primarydata.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <e62ae2e1-96d3-4759-c2d1-e449cdb7a945@Netapp.com>
Date: Fri, 26 Aug 2016 16:32:06 -0400
MIME-Version: 1.0
In-Reply-To: <20160729202024.GD7964@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/29/2016 04:20 PM, J. Bruce Fields wrote:
> On Fri, Jul 29, 2016 at 03:40:00PM -0400, Anna Schumaker wrote:
>> On 07/29/2016 02:59 PM, J. Bruce Fields wrote:
>>> On Fri, May 13, 2016 at 04:58:06PM -0400, Anna Schumaker wrote:
>>>> On 05/13/2016 04:31 PM, J. Bruce Fields wrote:
>>>>> On Sun, May 01, 2016 at 10:37:33AM -0700, Christoph Hellwig wrote:
>>>>>> I might sound like a broken record, but I'd feel much happier if this
>>>>>> had extensive xfstests coverage.  Xfstests has over one hundred tests for
>>>>>> file clones, and many of them should be easily adapatable.
>>>>>
>>>>> Anna, have you looked at this yet?
>>>>
>>>> Yep!  I just sent out what I came up with :)
>>>
>>> Sorry for the lack of response.  For some reason I don't seem to have
>>> the updated version in my mailboxes.  Do you have a more recent version?
>>
>> I'm not sure, so I'll make sure my code still works and then resubmit!
>>
>>>
>>>>> I don't see any obvious problem with the nfsd code, other than the
>>>>> obvious issue with large synchronous copies tying up server threads and
>>>>> leaving clients waiting--but maybe we should just see how people end up
>>>>> using it and deal with the problems as they come up.
>>>
>>> I'm still worrying about this, though.
>>>
>>> As a simple stopgap, could we just set *some* maximum on the size of the
>>> copy?  Or better yet on the time?--that'd let filesystems with
>>> clone-like features copy the whole file without blocking an nfsd thread
>>> indefinitely in the case of other filesystems.
>>
>> Would there be a good way of figuring out the time a copy would take?
> 
> Can we set some sort of timer to signal our thread after a limit?  Then
> hopefully the copy loop gets interrupted and we can return the amount
> copied so far.  (And hopefully the client has actually set the
> contiguous flag so it can continue where it left off.)
> 
>> Capping with an arbitrary size would definitely be simpler, so I'll
>> look into adding that.
> 
> I'm not sure how to set the limit.  The downside (assuming the
> client/application handle the short copy correctly) is that data can
> stop flowing while we wait for the client to send us the next copy, but
> I'm not sure how high the cap needs to be before that becomes
> negligible.

I've been playing around with copy caps and I found that a 4MB cap has performance pretty close to no cap at all.  Here is my performance data (averages across several runs):

|-------|---------|---------|---------|---------|---------|---------|---------|
|NFSv4.1|  512 MB | 1024 MB | 1536 MB | 2048 MB | 2560 MB | 3072 MB | 5120 MB |
|-------|---------|---------|---------|---------|---------|---------|---------|
|user   |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
|system |   0.28s |   0.48s |   0.72s |   0.94s |   1.17s |   1.42s |   2.37s |
|cpu    |     18% |     14% |     14% |     14% |     14% |     13% |     13% |
|total  |  1.547s |  3.269s |  5.040s |  6.690s |  8.363s | 10.146s | 16.729s |
|-------|---------|---------|---------|---------|---------|---------|---------|
|read   |   4096  |   8192  |  12288  |  16384  |  20480  |  24576  |  40960  |
|write  |   4098  |   8203  |  12302  |  16402  |  20497  |  24668  |  40996  |
|commit |      9  |     18  |     27  |     36  |     46  |     55  |     93  |
|-------|---------|---------|---------|---------|---------|---------|---------|

|-------|---------|---------|---------|---------|---------|---------|---------|
|No Cap |  512 MB | 1024 MB | 1536 MB | 2048 MB | 2560 MB | 3072 MB | 5120 MB |
|-------|---------|---------|---------|---------|---------|---------|---------|
|user   |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
|system |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
|cpu    |      0% |      0% |      0% |      0% |      0% |      0% |      0% |
|total  |  1.476s |  3.068s |  4.569s |  6.123s |  7.701s |  9.265s | 15.438s |
|-------|---------|---------|---------|---------|---------|---------|---------|
|copy   |      1  |      1  |      1  |      2  |      2  |      2  |      3  |
|commit |      1  |      1  |      1  |      2  |      2  |      2  |      3  |
|-------|---------|---------|---------|---------|---------|---------|---------|

|-------|---------|---------|---------|---------|---------|---------|---------|
|1MB Cap|  512 MB | 1024 MB | 1536 MB | 2048 MB | 2560 MB | 3072 MB | 5120 MB |
|-------|---------|---------|---------|---------|---------|---------|---------|
|user   |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
|system |   0.01s |   0.02s |   0.03s |   0.04s |   0.05s |   0.07s |   0.10s |
|cpu    |      0% |      0% |      0% |      0% |      0% |      0% |      0% |
|total  |  1.659s |  3.118s |  4.930s |  6.647s |  8.110s |  9.637s | 16.030s |
|-------|---------|---------|---------|---------|---------|---------|---------|
|copy   |    512  |   1024  |   1536  |   2048  |   2560  |   3072  |   5120  |
|commit |    512  |   1024  |   1536  |   2048  |   2560  |   3072  |   5120  |
|-------|---------|---------|---------|---------|---------|---------|---------|

|-------|---------|---------|---------|---------|---------|---------|---------|
|2MB Cap|  512 MB | 1024 MB | 1536 MB | 2048 MB | 2560 MB | 3072 MB | 5120 MB |
|-------|---------|---------|---------|---------|---------|---------|---------|
|user   |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
|system |   0.01s |   0.01s |   0.02s |   0.03s |   0.03s |   0.04s |   0.07s |
|cpu    |      0% |      0% |      0% |      0% |      0% |      0% |      0% |
|total  |  1.757s |  3.351s |  4.791s |  6.522s |  8.090s |  9.594s | 15.977s |
|-------|---------|---------|---------|---------|---------|---------|---------|
|copy   |    256  |    512  |    768  |   1024  |   1280  |   1536  |   2560  |
|commit |    256  |    512  |    768  |   1024  |   1280  |   1536  |   2560  |
|-------|---------|---------|---------|---------|---------|---------|---------|

|-------|---------|---------|---------|---------|---------|---------|---------|
|4MB Cap|  512 MB | 1024 MB | 1536 MB | 2048 MB | 2560 MB | 3072 MB | 5120 MB |
|-------|---------|---------|---------|---------|---------|---------|---------|
|user   |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
|system |   0.00s |   0.01s |   0.01s |   0.01s |   0.02s |   0.02s |   0.04s |
|cpu    |      0% |      0% |      0% |      0% |      0% |      0% |      0% |
|total  |  1.475s |  3.046s |  4.643s |  6.159s |  7.779s |  9.340s | 15.476s |
|-------|---------|---------|---------|---------|---------|---------|---------|
|copy   |    128  |    256  |    384  |    512  |    640  |    768  |   1280  |
|commit |    128  |    256  |    384  |    512  |    640  |    768  |   1280  |
|-------|---------|---------|---------|---------|---------|---------|---------|


If you don't have any objections then I'll put in the 4MB cap with a comment that it's to keep from holding open the RPC slot too long.  Then I'll resubmit that along with the xfstests I've written (and one vfs fix).

Thoughts?
Anna

> 
> --b.
> 

