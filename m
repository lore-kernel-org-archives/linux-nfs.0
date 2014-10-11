Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35784 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbaJKNcb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Oct 2014 09:32:31 -0400
Received: by mail-ig0-f177.google.com with SMTP id a13so5869107igq.10
        for <linux-nfs@vger.kernel.org>; Sat, 11 Oct 2014 06:32:31 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: WARNING at fs/nfs/write.c:743 nfs_inode_remove_request with -rc6
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <78B8153D-59B7-4DBE-8472-D83338F04338@primarydata.com>
Date: Sat, 11 Oct 2014 09:32:29 -0400
Cc: Peng Tao <tao.peng@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Message-Id: <6111EECC-C8C1-4605-98AD-0AF0E1B6DA59@primarydata.com>
References: <20140923130352.GK26472@arm.com> <2A327753-3E60-46AC-8220-3FF0FF61F08F@primarydata.com> <20140923135938.GB28608@arm.com> <20140923145356.GD28608@arm.com> <5294BEB2-F20F-4E3E-BFB2-E41806A4F85A@primarydata.com> <FA11FBE3-42E7-46B9-B9DA-FAE368DCE96B@primarydata.com> <F632C770-3E3D-4FC5-BBF3-69BB1CCA8F0D@primarydata.com> <20140923152558.GG28608@arm.com> <20140925171545.GR20043@arm.com> <78B8153D-59B7-4DBE-8472-D83338F04338@primarydata.com>
To: Will Deacon <will.deacon@arm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Will,

I’ve been very busy, but I haven’t forgotten about your bug report!

I think the WARN_ON_ONCE is just wrong, there are cases where the PG_INODE_REF
flag is legitimately not set. The flag is set so that sub requests can mimmic the parent
request’s reference count.

Could you please run the reproducer again, unmount, then check the contents of
/proc/fs/nfsfs/servers?

If it’s empty like example output below, then we know that requests are being properly
dereferenced.

# cat /proc/fs/nfsfs/servers 
NV SERVER   PORT USE HOSTNAME  
#

If there are any servers still listed (I’m assuming this is the only mount on your client for
the test), then we have a problem.

-dros



On Sep 25, 2014, at 1:27 PM, Weston Andros Adamson <dros@primarydata.com> wrote:

> On Sep 25, 2014, at 1:15 PM, Will Deacon <will.deacon@arm.com> wrote:
> 
>> Hi Andros,
>> 
>> On Tue, Sep 23, 2014 at 04:25:58PM +0100, Will Deacon wrote:
>>> On Tue, Sep 23, 2014 at 04:08:36PM +0100, Weston Andros Adamson wrote:
>>>> On Sep 23, 2014, at 11:02 AM, Weston Andros Adamson <dros@primarydata.com> wrote:
>>>>> Wait a second - the whole point of this extra reference (that the
>>>>> WARN_ON_ONCE is related to) is to handle the pass off to commit lists.
>>>>> 
>>>>> Maybe I’m just doing the wrong thing here with NFSv2!
>>>>> 
>>>>> More soon.
>>>> 
>>>> Actually, can you see if this is reproducible with NFSv3?
>>> 
>>> Just tried that, and I'm unable to trigger the problem with NFSv3.
>> 
>> Any more ideas? I can run with NFSv3 instead, but it's a shame to leave
>> v2 broken.
> 
> Hi Will,
> 
> I do plan on looking at this more very soon, but since it’s v2 only and just warning
> (and not crashing anything) it didn’t jump to the top of my list. It is only printing the
> warnings, right? That’s no reason to switch things up ;)
> 
> It might be interesting to get some rpcdebug output around the time of the warning,
> but I’m not sure it will be useful.
> 
> Since I cannot reproduce this, my next step is to inspect the code with an NFSv2
> with 64k pages setup in mind.
> 
> -dros

