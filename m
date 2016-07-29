Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:19815 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753601AbcG2UpC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2016 16:45:02 -0400
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
Message-ID: <a5e102ef-6078-ee6b-53b2-07339a306d25@Netapp.com>
Date: Fri, 29 Jul 2016 16:44:39 -0400
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

There are a lot of "hopefullys" there...  I'll look into timers and signals, since I haven't needed to use them yet.  What do you think would be a good maximum amount of time to copy before replying, assuming this way works out?

> 
>> Capping with an arbitrary size would definitely be simpler, so I'll
>> look into adding that.
> 
> I'm not sure how to set the limit.  The downside (assuming the
> client/application handle the short copy correctly) is that data can
> stop flowing while we wait for the client to send us the next copy, but
> I'm not sure how high the cap needs to be before that becomes
> negligible.

This probably changes based on if the underlying storage is a spinning disk or flash.  I'll poke around with the timer solution to see if I can figure that out, since it sounds more reliable.

Alternatively, would it be better for me to implement the callback portion and prepare the client for that?  Then you could blame the client for tying up an RPC slot if they request a large, synchronous copy :)

Anna

> 
> --b.
> 

