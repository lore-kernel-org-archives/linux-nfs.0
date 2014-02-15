Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:34465 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbaBOBqV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Feb 2014 20:46:21 -0500
From: Wuqixuan <wuqixuan@huawei.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Dr Fields James Bruce <bfields@fieldses.org>
CC: Linyongting <linyongting@huawei.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "wuqixuan@gmail.com" <wuqixuan@gmail.com>
Subject: RE: Help to know the stable ver of nfsv4 for commercial app 
Date: Sat, 15 Feb 2014 01:45:47 +0000
Message-ID: <BB7C62C2B0732E4DA93834A501E846456C8E9937@szxema505-mbx.china.huawei.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 15, 2014, at 1:12, trond.myklebust@primarydata.com wrote:

>> I don't know anything about the specific bug that you found.
>>
>> Based on https://lwn.net/Articles/585416/ 2.6.34 appears to be EOL'd as
>> of 2.6.34.15, so it would be up to you to support it past that.
>>
>> http://www.kernel.org/ lists which stable kernel branches are still
>> being updated.  I'm not sure where you find out how long those branches
>> are expected to be maintained.
>>
>> Someone who needs guaranteed support periods for "commercial use"
>> usually gets a contract with someone like my employer.  (And indeed the
>> enterprise distros do support NFSv4 on kernels that branched off before
>> 2.6.34).
>>

> I will not support kernels that are not listed as actively part of the ‘stable’ program; I simply don’t have the resources to do so.

> If you don’t want to go with an actively supported distribution kernel, I’d recommend going with kernel 3.10 rather than 3.12, simply because it is part of the 'long term release’ kernels (see https://www.kernel.org/category/releases.html ) and so will continue to receive updates until September 2015. That said, the fact that the kernel is in stable support doesn’t mean that we will be testing it actively for new bugs; it just means that we will be able to fix known bugs that have been discovered in newer kernels.

> If you need stronger guarantees than that, then I agree with Bruce that you should pick a distribution that offers long term software maintenance (which may require you to pay support fees).

Thank Trond and Bruce to reply. 

Currently, we are doing our Linux distribution based on 2.6.34.x. So no 
distribution OS support for us. All issues need to be fixed by us. 
Because we are not familiar with nfs protocal and the implementation, 
and 2.6.34.x is EOL already. So only if nfsv4 is stable enough (not many major bugs), 
then we can choose nfsv4 on 2.6.34.x. 

So now, our main doubt is just to want to know the stability of nfsv4 on 2.6.34.x. 
Because we found some many patch/commits merged in 3.x, but not merge into 2.6.34.x.
We want to know as per your experiences, are there many major bugs is not fixed in 2.6.34.x,
just fixed on 3.x ? 

Best Regards & Thanks a lot
--Wuqixuan