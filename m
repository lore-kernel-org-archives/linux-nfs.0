Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18926 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752175AbdHPUDt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 16:03:49 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 5/6] SUNRPC: Add a function to allow waiting for RPC transmission
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1502913733.5613.5.camel@primarydata.com>
Date: Wed, 16 Aug 2017 16:03:44 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <146ED3FC-ED3C-4153-A410-FC57B1C4A161@oracle.com>
References: <20170816161929.11271-1-trond.myklebust@primarydata.com> <20170816161929.11271-2-trond.myklebust@primarydata.com> <20170816161929.11271-3-trond.myklebust@primarydata.com> <20170816161929.11271-4-trond.myklebust@primarydata.com> <20170816161929.11271-5-trond.myklebust@primarydata.com> <20170816161929.11271-6-trond.myklebust@primarydata.com> <A0D358C7-C590-45CE-B4BF-F93BB08469B4@oracle.com> <1502913733.5613.5.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 16, 2017, at 4:02 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Wed, 2017-08-16 at 12:43 -0400, Chuck Lever wrote:
>>> On Aug 16, 2017, at 12:19 PM, Trond Myklebust <trond.myklebust@prim
>>> arydata.com> wrote:
>>> 
>>> Sometimes, we only want to know that the RPC message is in the
>>> process
>>> of being transmitted. Add a function to allow that.
>> 
>> The last time I tried these last two, they resulted in a significant
>> performance regression. Is there anything I can do to help track
>> that down?
> 
> If they are the root cause of a performance regression, then I'll just
> drop them. I've been rebasing to ensure that I keep them at the end of
> the queue precisely because I was unsure of their effect on overall
> performance.

My experience was applying the whole stack of the original 20
resulted in some performance degradations (fio). Popping these
two from that stack restored performance across the suite of
tests I was doing.


--
Chuck Lever



