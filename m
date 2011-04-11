Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.124]:52841 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624Ab1DKNgE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2011 09:36:04 -0400
Date: Mon, 11 Apr 2011 08:36:02 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Rob Landley <rlandley@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        containers@lists.linux-foundation.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Tim Spriggs <tims@uahirise.org>, Kir Kolyshkin <kir@parallels.com>,
        Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 3/3] Compare namespaces when comparing addresses in
 auth_unix cache.
Message-ID: <20110411133602.GA5321@hallyn.com>
References: <4D9431B3.2070305@parallels.com>
 <20110405034641.GC6764@hallyn.com>
 <4D9F24F2.9020603@parallels.com>
 <4DA30222.5040902@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DA30222.5040902@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Quoting Rob Landley (rlandley@parallels.com):
> On 04/08/2011 10:08 AM, Rob Landley wrote:
> > On 04/04/2011 10:46 PM, Serge E. Hallyn wrote:
> >> Does this need to take a reference?  Or is there no way for an
> >> entry to outlive its netns?  It sort of looks like
> >> svcauth_unix_info_release will ensure that doesn't happen, but
> >> I'm not convinced because other parts of the kernel can get
> >> to ip_map_init through the struct cache_detail.
> > 
> > When I wrote this I thought the transport's get_net() and put_net()
> > would pin it, but after re-reading, the sunrpc code is disgustingly
> > convoluted enough that I can't easily reconstruct my earlier reasoning.
> >  I'll add a get_net() and put_net() just to not have to worry about it.
> 
> Ah-ha!
> 
> Stanislav Kinsbursky helped me reconstruct some of the reasoning: we
> don't need to take a reference because we never actually dereference the
> struct net *, all we do is feed them to net_eq() which just compares the
> pointers for equality.  (The inline function exists so it can compile to
> a constant "return 1" when configured out.)
> 
> So if the network context did go away (which still shouldn't happen
> between the rpc_xprt and the struct nfs_client having references to it)
> we still wouldn't have a use-after-free problem because we're not
> looking at the memory, just the pointer.

Besides use-after-free, the other concern is an invalid net_eq()
result due to the * being re-used for a new netns.  I assume that's
deemed "super-duper impossible" again bc of the rpc_xprt/nfs_client
references to it?

> So I shouldn't need to add get_net() and put_net() to the cache.  Sound
> about right?

thanks,
-serge
