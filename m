Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28282 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdH3OVC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Aug 2017 10:21:02 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 0/7] Move nfs.conf to a shared library
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170830121522.GA16669@infradead.org>
Date: Wed, 30 Aug 2017 10:20:30 -0400
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Message-Id: <4C0B11C8-941C-4323-99D2-A355F5841BAF@oracle.com>
References: <1504093866.10850.1.camel@redhat.com> <20170830121522.GA16669@infradead.org>
To: Justin Mitchell <jumitche@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 30, 2017, at 8:15 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Wed, Aug 30, 2017 at 12:51:06PM +0100, Justin Mitchell wrote:
>> Moving the config parsing code out to a shared library fixes both
>> of these issues with minimal code changes. I appreciate that the 
>> API this library presents is less than ideal, it was left this way
>> to reduce code changes at this point, and i welcome suggestions for
>> a sympathetic approach to improving it.
> 
> The general shard code approach look good, but is there any good
> reason not to merge libnfsidmap into nfs-utils and make it a
> static (or at least a private shared) library instead of introducing
> a new ABI?

Agreed: who else is using libnfsidmap? Is there currently a packaging
requirement that keeps it outside of nfs-utils?


--
Chuck Lever



