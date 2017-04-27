Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34474 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937230AbdD0Cs3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 22:48:29 -0400
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: rdma connection close/reopen every 5 mins
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1493257558.129694.1.camel@primarydata.com>
Date: Wed, 26 Apr 2017 19:48:08 -0700
Cc: "scar@drigon.com" <scar@drigon.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <332BA8B5-8AD4-4374-BCAD-317BF87DCDE1@oracle.com>
References: <odql2m$vup$1@blaine.gmane.org> <97258237-282D-4A72-9AEE-BC1B82DF8E1C@oracle.com> <odr81f$k4m$1@blaine.gmane.org> <D82E4998-B2C0-42E5-B51B-4DA13ACB5BB2@oracle.com> <1493257558.129694.1.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 26, 2017, at 6:46 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Wed, 2017-04-26 at 15:52 -0700, Chuck Lever wrote:
>>> On Apr 26, 2017, at 3:47 PM, scar <scar@drigon.com> wrote:
>>> 
>>> Chuck Lever wrote on 04/26/2017 01:32 PM:
>>>> If it's every 5 minutes, that's probably the RPC idle timeout
>>>> that is closing the connection.
>>>> 
>>>> So this should be entirely harmless.
>>> 
>>> Yes so far it seems harmless, but it is annoying and fills up the
>>> log with spam, plus it's not something I see when using NFS/TCP.
>> 
>> That's correct, NFS/TCP does not have the "connected / closed"
>> messages, but the idle timeout behavior is the exactly the same.
>> 
>> I tried to remove those messages a few years ago and was told
>> to go pound sand.
>> 
> 
> 
> By me?

No, I filed a bug on bugzilla.kernel.org and I think it was
Alan Cox (!) who told me to leave these alone.


> I’d be happy to take a patch to remove those messages. I find it
> absolutely ridiculous to be logging fully expected behaviour like this.
> It should at best be a dprintk() and I'd prefer to replace it with
> tracepoints like we do for the socket code.

I can send a patch for 4.13 that converts these to
dprintks for now. Tracepoints are definitely in plan...



