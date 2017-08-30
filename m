Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42236 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750757AbdH3UdN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Aug 2017 16:33:13 -0400
Subject: Re: [PATCH 0/7] Move nfs.conf to a shared library
To: Chuck Lever <chuck.lever@oracle.com>,
        Justin Mitchell <jumitche@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
References: <1504093866.10850.1.camel@redhat.com>
 <20170830121522.GA16669@infradead.org>
 <4C0B11C8-941C-4323-99D2-A355F5841BAF@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <bd61a590-6084-1daa-9dcc-471d6ab0f8ee@RedHat.com>
Date: Wed, 30 Aug 2017 16:33:12 -0400
MIME-Version: 1.0
In-Reply-To: <4C0B11C8-941C-4323-99D2-A355F5841BAF@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/30/2017 10:20 AM, Chuck Lever wrote:
> 
>> On Aug 30, 2017, at 8:15 AM, Christoph Hellwig <hch@infradead.org> wrote:
>>
>> On Wed, Aug 30, 2017 at 12:51:06PM +0100, Justin Mitchell wrote:
>>> Moving the config parsing code out to a shared library fixes both
>>> of these issues with minimal code changes. I appreciate that the 
>>> API this library presents is less than ideal, it was left this way
>>> to reduce code changes at this point, and i welcome suggestions for
>>> a sympathetic approach to improving it.
>>
>> The general shard code approach look good, but is there any good
>> reason not to merge libnfsidmap into nfs-utils and make it a
>> static (or at least a private shared) library instead of introducing
>> a new ABI?
> 
> Agreed: who else is using libnfsidmap? Is there currently a packaging
> requirement that keeps it outside of nfs-utils?
I hope not... and I agree... lets use this effort to roll
libnfsidmap into nfs-utils as static library.

The pain is more of a logistics issue for distro... IMHO...

steved.

