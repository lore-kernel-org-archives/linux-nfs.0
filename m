Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy7-pub.bluehost.com ([67.222.55.9]:35285 "HELO
	oproxy7-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752809Ab1K2Wkv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 17:40:51 -0500
Message-ID: <4ED56D2E.6050405@xenotime.net>
Date: Tue, 29 Nov 2011 15:39:26 -0800
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@tonian.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, Michal Marek <mmarek@suse.cz>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: ore: FIX breakage when MISC_FILESYSTEMS is not set
References: <20111124174358.d88f11c0ff700e5e6b3bf73b@canb.auug.org.au>  <4ECE91F3.9010007@xenotime.net> <4ED422CC.60706@panasas.com>  <4ED4238F.4090407@panasas.com> <4ED4CE58.8090107@tonian.com> <1322588023.4174.28.camel@lade.trondhjem.org> <4ED55B3B.9050207@panasas.com>
In-Reply-To: <4ED55B3B.9050207@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 02:22 PM, Boaz Harrosh wrote:
> On 11/29/2011 09:33 AM, Trond Myklebust wrote:
>> On Tue, 2011-11-29 at 14:21 +0200, Benny Halevy wrote: 
>>> On 2011-11-29 02:13, Boaz Harrosh wrote:
> 
>>>>
>>>> The solution is to force all users of ORE (exofs, nfs) to manually
>>>> select everything auto-magically selected before.
>>>
>>> How about using "depend ORE" rather than "select ORE"?
>>
>> Right. Make PNFS_OBJLAYOUT and EXOFS_FS depend on ASYNC_XOR (or select
>> it) and then make ORE depend on EXOFS_FS || PNFS_OBJLAYOUT.
>>
>> There should be no need to add the 'select ORE'...
>>
> 
> No! guys!
> 
> One it will not solve my problem because any
> solution that needs to inspect exofs/Kconfig file will
> not work if MISC_FILESYSTEMS is not selected and your
> solutions involve that.
> 
> And two:
> All the user needs to do is Select NFS4.1 everything
> else should be done automatically. He should not need
> to go to misc-filesystems and select ORE so he can have
> pnfs-objects. That's a nightmare.
> 
> And anyway the current Kernel rule is that a user of a library
> needs to select it and all it's dependencies, because select
> is not recursive. Now I devised a little skim that can avoid

Since 'select' is not recursive, how does the "select ASYNC_XOR"
handle ensuring that what it selects (ASYNC_CORE and XOR_BLOCKS)
have been enabled?

> that, which is not conventional but works very nice. It was
> almost good enough only we have the problem that exofs is under
> that big MISC_FILESYSTEMS nub.
> 
> So It's the regular Kernel way, for now.
> 
> (The real solution is to move ORE to lib/ which would enable my
>  clever trick. But I don't want to go there only because of that)
> 
> I'll fix the typos though

With the patch applied, I am still seeing this kconfig warning:

warning: (PNFS_OBJLAYOUT) selects ORE which has unmet direct dependencies (MISC_FILESYSTEMS)


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
