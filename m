Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa08-01.prod.phx3.secureserver.net ([173.201.193.102]:51061
	"EHLO p3plsmtpa08-01.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932185AbcBAWBp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 17:01:45 -0500
Subject: Re: [RFC PATCH v3 00/13] Basic multipathing support and demonstrator
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <1454347277-10997-1-git-send-email-trond.myklebust@primarydata.com>
 <20160201204825.GD5499@fieldses.org>
 <CAHQdGtSYnL905dj=P_HDdgXPHgrFWEzFnzFu54SjaHEP=UpREQ@mail.gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Tom Talpey <tom@talpey.com>
Message-ID: <56AFD431.4050004@talpey.com>
Date: Mon, 1 Feb 2016 16:54:57 -0500
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSYnL905dj=P_HDdgXPHgrFWEzFnzFu54SjaHEP=UpREQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/1/2016 4:12 PM, Trond Myklebust wrote:
> On Mon, Feb 1, 2016 at 3:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>
>> On Mon, Feb 01, 2016 at 12:21:04PM -0500, Trond Myklebust wrote:
>>> The following patchset is intended as an RFC to demonstrate how we could
>>> implement multipathing in NFS.
>>> It adds basic support for attaching multiple RPC transports to a client,
>>> an embryonic policy mechanism for switching tasks across those transports
>>> (with a round-robin policy implementation),...
>>
>> Since your prototype is doing round-robin per task, I assume the
>> motivating problem is that you don't want to waste bandwidth when
>> there's multiple links available.  Is that right, or is there some other
>> goal you have in mind?
>>
>
> I did round-robin simply because it is easy to do, and because server
> vendors have been asking for it. That said, the policy is readily
> pluggable, and it should be straightforward to add path failover,
> should you want to.

I think servers probably want load balancing, which is not quite the
same thing as round robin. When we implemented mulitchannel in SMB3,
we quickly discovered many issues at scale, especially when network
links introduced additional variance. We eventually settled on a
selection method that attempted to balance outstanding queue depth,
as well as round robining.

Do you plan to support links of different speed or other characteristics
e.g. mixing TCP and RDMA? That introduces a number of other issues; in
SMB3 we simply avoid ever doing those. Channel selection can also be
used to tune multiprocessor affinity. There were Storage Developer
Conference talks back in 2012 and maybe 2013 that discussed the approaches.

You may also want to talk to the Samba folks, who are implementing SMB3
multichannel (server) recently, and may have insight to share.

All that said, it's great to see this.

Tom.
