Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54856 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752941AbeDQOlq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 10:41:46 -0400
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
To: Olga Kornievskaia <aglo@umich.edu>,
        Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org>
 <20180417065203.GA15145@infradead.org>
 <CAN-5tyEjCEo+P=p2nPkEiwa3BwM8Nj_N3KmvMXMU+VDmQJcjLA@mail.gmail.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <1b45673f-516d-51ff-a1ef-8b07b9dd8619@RedHat.com>
Date: Tue, 17 Apr 2018 10:41:32 -0400
MIME-Version: 1.0
In-Reply-To: <CAN-5tyEjCEo+P=p2nPkEiwa3BwM8Nj_N3KmvMXMU+VDmQJcjLA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/17/2018 09:22 AM, Olga Kornievskaia wrote:
> On Tue, Apr 17, 2018 at 2:52 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> On Mon, Apr 16, 2018 at 05:45:22PM -0400, J. Bruce Fields wrote:
>>> On Sat, Apr 14, 2018 at 12:22:02AM -0700, Christoph Hellwig wrote:
>>>> What is the use case for adding all these crazy complications?
>>>
>>> Is there anything specific that you think is too complicated?
>>
>> It is a lot of complexity for little gain.
>>
>>> I know you don't think server-to-server copy offload is worth the
>>> trouble, but I haven't seen you actually explain why (beyond just that
>>> it's more complicated).
>>
>> I'd like to see numbers for actual, real use cases.  Note that this
>> series doesn't seem to include inter-server support, so this is locally
>> only, and I'd like to see why we want to support this over the simpler
>> and better performing CLONE op.
>>
>> Also even if we have a good reason to add it I absolutely want a config
>> option for the feature - it is a lot code adding potential attack
>> vectors, so we should not just enabled it by default.
>>
>>> Is there some reason you think it won't actually be useful?
>>
>> Lets start with explaining why it would actually be useful and benefit
>> Linux users.
> 
> This is performance improvement feature. Why do you keep asking about
> benefits? Besides my employer I had other companies chime in on this
> mailing list that they are interested in the copy offload feature
> therefore this work is being done.
+1 I guess I don't see why people would object to a performance
improvement... Do you?

> 
> Yes this series only introduced asynchronous copy offload because the
> concern was that doing "inter"+asynchronous was too much to review and
> therefore it is being done in parts.
Which is a solid plan... IMHO... But the bottom line is this... 

A decision needs to be made... Either accept these patches/concept or don't!
This discussion has been going on quite a while now... If this
performance improvement is not something the community wants
so be bit.. Make the call... so we can move on... 
 
> 
> I have no objections to having a configuration option for this
> feature. It would be up to the Linux distributions to "make is a
> default". Bruce/Anna/Trond, do you want this code to be ifdef-ed under
> a config option(s) (one for the client and one for the server)?
Way is this needed? Why wouldn't users want a performance gain on
by default??

steved.
 
