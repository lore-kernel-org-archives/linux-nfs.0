Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:43571 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868Ab1JaVfP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 17:35:15 -0400
Message-ID: <4EAF146D.5060507@panasas.com>
Date: Mon, 31 Oct 2011 14:34:37 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [patchset 0/8] pnfs-obj: Move to ORE for v3.2 merge window
References: <4EAAFED8.7020600@panasas.com> <1319909073.2760.7.camel@lade.trondhjem.org> <4EAEDFA6.4080303@panasas.com>
In-Reply-To: <4EAEDFA6.4080303@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/31/2011 10:49 AM, Boaz Harrosh wrote:
> On 10/29/2011 10:24 AM, Trond Myklebust wrote:
>> Hi Boaz,
>>
>> Have you tested these patches in linux-next? If so, I can pull them in
>> from open-osd.org and send them with the next merge. If not, I think
>> patches (as soon as possible!) would be better. I'll commit them to
>> nfs-for-next, and we can try to get them in...
>>
>> Cheers
>>   Trond
>>
> 
> Hi Trond.
> 
> These patches where in next since before the BAT when I sent them to the
> list, then based on my exofs tree. I have now rebased on Linus master
> based on my pull bits and Yours, and again they where in next since
> Thursday. But the big question is did we have linux-next in that time
> frame because I thought Stephen was on vacation and the last linux-next
> was around Oct 20th?
> 
> Any way both our bits where in Linux next since Oct 16. The patches are
> rebased but completely unchanged.
> 
> Is there some tests I should make, other then compile oldmodconfig x86_64
> and x86_32? I wish I had setup for more compilers. 
> 
> But I'd say the risk is very low since the exact patches did sit in next.
> And after rebase I run a compile and a short test run.
> 
> Any way I can post the patches. Give me an hour
> Boaz
> 

Hi trond

I just re-checked. Compiled both i386 an x86_64 allmodconfig and even
merge with latest linus tree. I sign on these patches.

Again they were in linux-next as is, untouched based on exofs tree.
And now based on Linus/master [f362f98] They compile and run.

I'll re-post them just in case you decide to need them, as reply to
this mail.

Thanks
Boaz
