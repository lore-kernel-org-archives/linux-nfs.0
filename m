Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57643 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752842AbaBQPN4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Feb 2014 10:13:56 -0500
Date: Mon, 17 Feb 2014 10:13:29 -0500
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Wuqixuan <wuqixuan@huawei.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linyongting <linyongting@huawei.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "wuqixuan@gmail.com" <wuqixuan@gmail.com>
Subject: Re: Help to know the stable ver of nfsv4 for commercial app
Message-ID: <20140217151329.GA32181@fieldses.org>
References: <BB7C62C2B0732E4DA93834A501E846456C8E9937@szxema505-mbx.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <BB7C62C2B0732E4DA93834A501E846456C8E9937@szxema505-mbx.china.huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 15, 2014 at 01:45:47AM +0000, Wuqixuan wrote:
> On Feb 15, 2014, at 1:12, trond.myklebust@primarydata.com wrote:
> 
> >> I don't know anything about the specific bug that you found.
> >>
> >> Based on https://lwn.net/Articles/585416/ 2.6.34 appears to be EOL'd as
> >> of 2.6.34.15, so it would be up to you to support it past that.
> >>
> >> http://www.kernel.org/ lists which stable kernel branches are still
> >> being updated.  I'm not sure where you find out how long those branches
> >> are expected to be maintained.
> >>
> >> Someone who needs guaranteed support periods for "commercial use"
> >> usually gets a contract with someone like my employer.  (And indeed the
> >> enterprise distros do support NFSv4 on kernels that branched off before
> >> 2.6.34).
> >>
> 
> > I will not support kernels that are not listed as actively part of the ‘stable’ program; I simply don’t have the resources to do so.
> 
> > If you don’t want to go with an actively supported distribution kernel, I’d recommend going with kernel 3.10 rather than 3.12, simply because it is part of the 'long term release’ kernels (see https://www.kernel.org/category/releases.html ) and so will continue to receive updates until September 2015. That said, the fact that the kernel is in stable support doesn’t mean that we will be testing it actively for new bugs; it just means that we will be able to fix known bugs that have been discovered in newer kernels.
> 
> > If you need stronger guarantees than that, then I agree with Bruce that you should pick a distribution that offers long term software maintenance (which may require you to pay support fees).
> 
> Thank Trond and Bruce to reply. 
> 
> Currently, we are doing our Linux distribution based on 2.6.34.x. So no 
> distribution OS support for us. All issues need to be fixed by us. 
> Because we are not familiar with nfs protocal and the implementation, 
> and 2.6.34.x is EOL already. So only if nfsv4 is stable enough (not many major bugs), 
> then we can choose nfsv4 on 2.6.34.x. 
> 
> So now, our main doubt is just to want to know the stability of nfsv4 on 2.6.34.x. 
> Because we found some many patch/commits merged in 3.x, but not merge into 2.6.34.x.
> We want to know as per your experiences, are there many major bugs is not fixed in 2.6.34.x,
> just fixed on 3.x ? 

Sorry, that's just a harder question to answer than you realize.
Neither of us are going to be comfortable answering that question
without a lot of active testing or direct experience supporting that
particular kernel.  You either need to do that sort of work yourself or
find someone else who has.

--b.
