Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49602 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754010Ab2JBWbQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 18:31:16 -0400
Subject: Re: [REGRESSION] nfsd crashing with 3.6.0-rc7 on PowerPC
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Alexander Graf <agraf@suse.de>
In-Reply-To: <20121002221736.GB29218@linux.vnet.ibm.com>
Date: Wed, 3 Oct 2012 00:31:09 +0200
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, anton@samba.org,
        skinsbursky@parallels.com, bfields@redhat.com,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Message-Id: <E141CA01-F58C-47B1-8ED5-A314D1DEC968@suse.de>
References: <3BDA9E62-7031-42D6-8CA9-5327B61700F5@suse.de> <CA+55aFyXwB1QcXE4Z_FAGnXROSgvP2x2+wjnX9OWPa4Dfaaf0A@mail.gmail.com> <DC545CD9-8745-47DD-B13B-3385C0EB5B27@suse.de> <20120928151043.GA19102@fieldses.org> <2A52FC96-148C-4F7A-9950-E152E0C6698D@suse.de> <1349139509.3847.2.camel@pasglop> <20121002214327.GA29218@linux.vnet.ibm.com> <9257E705-4EF9-4347-945C-B4A7582C427F@suse.de> <20121002221736.GB29218@linux.vnet.ibm.com>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 03.10.2012, at 00:17, Nishanth Aravamudan wrote:

> On 02.10.2012 [23:47:39 +0200], Alexander Graf wrote:
>> 
>> On 02.10.2012, at 23:43, Nishanth Aravamudan wrote:
>> 
>>> Hi Ben,
>>> 
>>> On 02.10.2012 [10:58:29 +1000], Benjamin Herrenschmidt wrote:
>>>> On Mon, 2012-10-01 at 16:03 +0200, Alexander Graf wrote:
>>>>> Phew. Here we go :). It looks to be more of a PPC specific problem
>>>>> than it appeared as at first:
>>>> 
>>>> Ok, so I suspect the problem is the pushing down of the locks which
>>>> breaks with iommu backends that have a separate flush callback. In
>>>> that case, the flush moves out of the allocator lock.
>>>> 
>>>> Now we do call flush before we return, still, but it becomes racy
>>>> I suspect, but somebody needs to give it a closer look. I'm hoping
>>>> Anton or Nish will later today.
>>> 
>>> Started looking into this. If your suspicion were accurate, wouldn't the
>>> bisection have stopped at 0e4bc95d87394364f408627067238453830bdbf3
>>> ("powerpc/iommu: Reduce spinlock coverage in iommu_alloc and
>>> iommu_free")?
>>> 
>>> Alex, the error is reproducible, right?
>> 
>> Yes. I'm having a hard time to figure out if the reason my U4 based G5
>> Mac crashes and fails reading data is the same since I don't have a
>> serial connection there, but I assume so.
> 
> Ok, great, thanks. Yeah, that would imply (I think) that the I would
> have thought the lock pushdown in the above commit (or even in one of
> the others in Anton's series) would have been the real source if it was
> a lock-based race. But that's just my first sniff at what Ben was
> suggesting. Still reading/understanding the code.
> 
>>> Does it go away by reverting
>>> that commit against mainline? Just trying to narrow down my focus.
>> 
>> The patch doesn't revert that easily. Mind to provide a revert patch
>> so I can try?
> 
> The following at least builds on defconfig here:

Yes. With that patch applied, things work for me again.


Alex

