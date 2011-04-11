Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:39773 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007Ab1DKN3w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Apr 2011 09:29:52 -0400
Message-ID: <4DA30222.5040902@parallels.com>
Date: Mon, 11 Apr 2011 08:29:06 -0500
From: Rob Landley <rlandley@parallels.com>
To: "Serge E. Hallyn" <serge@hallyn.com>
CC: <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <containers@lists.linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Tim Spriggs <tims@uahirise.org>, Kir Kolyshkin <kir@parallels.com>,
        Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 3/3] Compare namespaces when comparing addresses in auth_unix
 cache.
References: <4D9431B3.2070305@parallels.com> <20110405034641.GC6764@hallyn.com> <4D9F24F2.9020603@parallels.com>
In-Reply-To: <4D9F24F2.9020603@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/08/2011 10:08 AM, Rob Landley wrote:
> On 04/04/2011 10:46 PM, Serge E. Hallyn wrote:
>> Does this need to take a reference?  Or is there no way for an
>> entry to outlive its netns?  It sort of looks like
>> svcauth_unix_info_release will ensure that doesn't happen, but
>> I'm not convinced because other parts of the kernel can get
>> to ip_map_init through the struct cache_detail.
> 
> When I wrote this I thought the transport's get_net() and put_net()
> would pin it, but after re-reading, the sunrpc code is disgustingly
> convoluted enough that I can't easily reconstruct my earlier reasoning.
>  I'll add a get_net() and put_net() just to not have to worry about it.

Ah-ha!

Stanislav Kinsbursky helped me reconstruct some of the reasoning: we
don't need to take a reference because we never actually dereference the
struct net *, all we do is feed them to net_eq() which just compares the
pointers for equality.  (The inline function exists so it can compile to
a constant "return 1" when configured out.)

So if the network context did go away (which still shouldn't happen
between the rpc_xprt and the struct nfs_client having references to it)
we still wouldn't have a use-after-free problem because we're not
looking at the memory, just the pointer.

So I shouldn't need to add get_net() and put_net() to the cache.  Sound
about right?

Rob
