Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:57192 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731933AbeG0DH5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2018 23:07:57 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [BUG BISECT] NFSv4 client fails on Flush Journal to Persistent
 Storage
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAJKOXPejStfaQdtUwh33v+aC7KpamoLkix3nitbHrDRx4QAR6g@mail.gmail.com>
Date: Thu, 26 Jul 2018 21:48:06 -0400
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        "sudeep.holla@arm.com" <sudeep.holla@arm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "linux-samsung-soc@vger.kernel.org"
        <linux-samsung-soc@vger.kernel.org>
Message-Id: <63E567B6-ACC6-449F-95F6-1F17102221F1@oracle.com>
References: <CAJKOXPd2rntNOpU1quR9Zm_J22+=pEaj4ZTC_tdZ0zcRYUciFg@mail.gmail.com>
 <CAPKp9uZ79ybkv7dMpcy2GQ9L+rWk+vdExQ48diWWQPOUdDQtSQ@mail.gmail.com>
 <CAJKOXPfX0CytKcYDaDAYYuCQjk-mcGjFRHfZco-wPQsc4G1agA@mail.gmail.com>
 <BCD39D7E-EEEC-4EB9-824E-63323C333C88@oracle.com>
 <CAJKOXPcw-i99_U-Ltuuf6w-WRK7V4gNqVSYkCMGFEXQG2DL2XQ@mail.gmail.com>
 <CAJKOXPf7V1z4pNZ2RsjkJmaVAgk34_rPOtQOc7J5KRMSRemrdg@mail.gmail.com>
 <082848F5-6360-4523-BA95-601777E17CF2@oracle.com>
 <CAJKOXPe4uqOZGd_zb_Mqq4Fspu63LHZky86O4tPaD3BZNCBS6w@mail.gmail.com>
 <6AAC5897-8762-4209-8718-67291B87AA00@oracle.com>
 <d617f8a85c3414230cd755fe0e4470c0f8bd17ff.camel@hammerspace.com>
 <26995E49-E8DD-421D-BABF-9E672B9383BD@oracle.com>
 <30a1455b6817361f8228c022628aef5cdee70c3e.camel@hammerspace.com>
 <784782B0-A387-4D3B-A517-E85D851162B8@oracle.com>
 <CAJKOXPfMiaGP9xqPcOQMs+a4RKvhK03v51e5r3GaUiFs0G=61Q@mail.gmail.com>
 <9B9E1627-AC2E-4A0C-AB6E-5815876A59AB@oracle.com>
 <CAJKOXPejStfaQdtUwh33v+aC7KpamoLkix3nitbHrDRx4QAR6g@mail.gmail.com>
To: Krzysztof Kozlowski <krzk@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jul 26, 2018, at 4:46 AM, Krzysztof Kozlowski <krzk@kernel.org> wrote:
> 
> On 25 July 2018 at 16:31, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> 
>>> On Jul 25, 2018, at 9:27 AM, Krzysztof Kozlowski <krzk@kernel.org> wrote:
>>> 
>>> On 18 June 2018 at 18:20, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> 
>>>> The extra serialization appears to have a reproducible performance
>>>> impact on RDMA, which no longer takes the reserve_lock when allocating
>>>> a slot.
>>>> 
>>>> I could put an xprt_alloc_xid call in xprt_alloc_slot, but that would
>>>> only work for socket-based transports. Would it be OK if RDMA had its
>>>> own XID allocation mechanism?
>>> 
>>> Hi,
>>> 
>>> On recent next the issue appeared again. My boards with NFSv4 root
>>> timeout on 80% of boots. This time my NFS server is faster - Pi3 B+
>>> :).
>>> 
>>> Is this know? Should I start long bisect or maybe you can point me to
>>> possible causes?
>> 
>> Hi Krzysztof, I don't know of any recent changes. Bisecting would be
>> a good place to start.
> 
> Hi,
> 
> That was my mistake because of missing part of NFS server
> configuration on new board. I tested again recent releases and current
> linux-next and everything works fine.
> 
> Sorry for the noise.

Thanks for the update.


--
Chuck Lever



