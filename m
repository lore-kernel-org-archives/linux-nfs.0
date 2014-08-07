Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48476 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757345AbaHGNOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2014 09:14:08 -0400
Message-ID: <53E37B96.8040807@RedHat.com>
Date: Thu, 07 Aug 2014 09:13:58 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, Peng Tao <bergwolf@gmail.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        "faibish, sorin" <faibish_sorin@emc.com>
Subject: Re: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger
 than page size
References: <1407396229-4785-1-git-send-email-hch@lst.de> <1407396229-4785-9-git-send-email-hch@lst.de> <CA+a=Yy42e46zA+X-VQQj9RAzZ4T+A7dOOrjUMVONsh8Pt8QdcQ@mail.gmail.com> <20140807112537.GA3437@lst.de>
In-Reply-To: <20140807112537.GA3437@lst.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/07/2014 07:25 AM, Christoph Hellwig wrote:
> On Thu, Aug 07, 2014 at 06:43:14PM +0800, Peng Tao wrote:
>> > So this kills EMC server support.
> Given the state the code  claiming support for any server is a large
> exaggeration..
> 
But eliminating the potential of supporting block layouts
does not sound like a very good idea to me.... 

There are rumors of other block layouts implementations
coming down the pike.... So hopefully we don't eliminating
any and all possible support of block layouts in the future...

steved.
