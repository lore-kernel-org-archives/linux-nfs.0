Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:58548 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaBNRMs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Feb 2014 12:12:48 -0500
Received: by mail-ie0-f177.google.com with SMTP id rp18so2697144iec.22
        for <linux-nfs@vger.kernel.org>; Fri, 14 Feb 2014 09:12:48 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: Help to know the stable ver of nfsv4 for commercial app
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140214155358.GG21982@fieldses.org>
Date: Fri, 14 Feb 2014 12:12:45 -0500
Cc: Wuqixuan <wuqixuan@huawei.com>, Linyongting <linyongting@huawei.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "wuqixuan@gmail.com" <wuqixuan@gmail.com>
Message-Id: <09EF05F4-F14E-42DD-8689-C28E11E43F34@primarydata.com>
References: <BB7C62C2B0732E4DA93834A501E846456C8E98D7@szxema505-mbx.china.huawei.com> <20140214155358.GG21982@fieldses.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 14, 2014, at 10:53, bfields@fieldses.org wrote:

> On Fri, Feb 14, 2014 at 08:55:11AM +0000, Wuqixuan wrote:
>> Hi Trond, Bfields, All, 
>> 
>> We are useing nfsv3 in 2.6.34.13 kernel for commucial use. For some reasons(such as security), has requirement to upgrade to nfsv4(still on 2.6.34.x kernel). We did two things: 
>> 
>> 1. I passed through the git log of kernel.org of nfs, found after 2010(2.6.34 is released on May 2010, and no update on 2.6.34.x for nfs/nfsd), just for sampling, nfsd/nfs4proc.c has 460 commits while nfs/nfs3proc.c has only 38 commits. 
>> 2. Just enable nfsv4 on 2.6.34.13, got problem(EIO) on just a simple open. Found it's because of one commit(https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=a2c0b9e291208f65221a0ad8a0c80a377707d480), simply remove this commit, now can simply use nfsv4 on 2.6.34.13. 
>> 
>> So we are worried about the stability of nfsv4 on 2.6.34.x. 
>> If any one has some idea or information about: 
>> 
>>    1. Whether nfsv4 (including nfs/nfs4/sunrpc) of 2.6.34.x is stable enough for commercial use or not.
>>    2. If nfsv4 is not stable enough on 2.6.34.x, which version can we use , 3.10 ? or 3.12 ? 
>>    3. Is there any mature commercial application on nfsv4 on 2.6.34.x or before? Can tell some famous company or app name ?
> 
> I don't know anything about the specific bug that you found.
> 
> Based on https://lwn.net/Articles/585416/ 2.6.34 appears to be EOL'd as
> of 2.6.34.15, so it would be up to you to support it past that.
> 
> http://www.kernel.org/ lists which stable kernel branches are still
> being updated.  I'm not sure where you find out how long those branches
> are expected to be maintained.
> 
> Someone who needs guaranteed support periods for "commercial use"
> usually gets a contract with someone like my employer.  (And indeed the
> enterprise distros do support NFSv4 on kernels that branched off before
> 2.6.34).
> 

I will not support kernels that are not listed as actively part of the ‘stable’ program; I simply don’t have the resources to do so.

If you don’t want to go with an actively supported distribution kernel, I’d recommend going with kernel 3.10 rather than 3.12, simply because it is part of the 'long term release’ kernels (see https://www.kernel.org/category/releases.html ) and so will continue to receive updates until September 2015. That said, the fact that the kernel is in stable support doesn’t mean that we will be testing it actively for new bugs; it just means that we will be able to fix known bugs that have been discovered in newer kernels.

If you need stronger guarantees than that, then I agree with Bruce that you should pick a distribution that offers long term software maintenance (which may require you to pay support fees).

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

