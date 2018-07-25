Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:37626 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728358AbeGYOj3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Jul 2018 10:39:29 -0400
MIME-Version: 1.0
In-Reply-To: <784782B0-A387-4D3B-A517-E85D851162B8@oracle.com>
References: <CAJKOXPd2rntNOpU1quR9Zm_J22+=pEaj4ZTC_tdZ0zcRYUciFg@mail.gmail.com>
 <CAPKp9uZ79ybkv7dMpcy2GQ9L+rWk+vdExQ48diWWQPOUdDQtSQ@mail.gmail.com>
 <CAJKOXPfX0CytKcYDaDAYYuCQjk-mcGjFRHfZco-wPQsc4G1agA@mail.gmail.com>
 <BCD39D7E-EEEC-4EB9-824E-63323C333C88@oracle.com> <CAJKOXPcw-i99_U-Ltuuf6w-WRK7V4gNqVSYkCMGFEXQG2DL2XQ@mail.gmail.com>
 <CAJKOXPf7V1z4pNZ2RsjkJmaVAgk34_rPOtQOc7J5KRMSRemrdg@mail.gmail.com>
 <082848F5-6360-4523-BA95-601777E17CF2@oracle.com> <CAJKOXPe4uqOZGd_zb_Mqq4Fspu63LHZky86O4tPaD3BZNCBS6w@mail.gmail.com>
 <6AAC5897-8762-4209-8718-67291B87AA00@oracle.com> <d617f8a85c3414230cd755fe0e4470c0f8bd17ff.camel@hammerspace.com>
 <26995E49-E8DD-421D-BABF-9E672B9383BD@oracle.com> <30a1455b6817361f8228c022628aef5cdee70c3e.camel@hammerspace.com>
 <784782B0-A387-4D3B-A517-E85D851162B8@oracle.com>
From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Wed, 25 Jul 2018 15:27:46 +0200
Message-ID: <CAJKOXPfMiaGP9xqPcOQMs+a4RKvhK03v51e5r3GaUiFs0G=61Q@mail.gmail.com>
Subject: Re: [BUG BISECT] NFSv4 client fails on Flush Journal to Persistent Storage
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        "sudeep.holla@arm.com" <sudeep.holla@arm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "linux-samsung-soc@vger.kernel.org"
        <linux-samsung-soc@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18 June 2018 at 18:20, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> The extra serialization appears to have a reproducible performance
> impact on RDMA, which no longer takes the reserve_lock when allocating
> a slot.
>
> I could put an xprt_alloc_xid call in xprt_alloc_slot, but that would
> only work for socket-based transports. Would it be OK if RDMA had its
> own XID allocation mechanism?

Hi,

On recent next the issue appeared again. My boards with NFSv4 root
timeout on 80% of boots. This time my NFS server is faster - Pi3 B+
:).

Is this know? Should I start long bisect or maybe you can point me to
possible causes?

Best regards,
Krzysztof
