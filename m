Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751969Ab2JVKwR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Oct 2012 06:52:17 -0400
Date: Mon, 22 Oct 2012 06:52:00 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jan Sanislo <oystr@cs.washington.edu>
Cc: linux-nfs@vger.kernel.org, keyrings@linux-nfs.org
Subject: Re: nfsidmap and NFS key timeouts and quotas
Message-ID: <20121022065200.25fd18e0@tlielax.poochiereds.net>
In-Reply-To: <1350849102/oystr@maui.cs.washington.edu>
References: <1350849102/oystr@maui.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 21 Oct 2012 13:15 PDT
Jan Sanislo <oystr@cs.washington.edu> wrote:

> > Nice catch. The rpc.idmapd downcall handler does this already in the
> > kernel:
> >
> >        ret = nfs_idmap_read_and_verify_message(&im,
> >                        &idmap->idmap_upcall_data->idmap_msg,
> >                        cons->key, cons->authkey);
> >        if (ret >= 0) {
> >                key_set_timeout(cons->key, nfs_idmap_cache_timeout);
> >                ret = mlen;
> >        }
> >
> > ...where nfs_idmap_cache_timeout defaults to 600 and is tunable via
> > module parameter. Might it be better for consistency's sake to make the
> > keys API upcall do the same thing?
> 
> Yes, that certainly works.  But I wonder whether it's conspicuous
> absence on that call path wasn't intentional, with the intent being
> to make request-keys/nfsidmap the single stop for setting NFS key
> timeouts.  If the key_set_timeout call moves into the kernel then
> it would be useful to remove the nfsidmap code and docs regarding
> key timeouts -- otherwise things might get a littel confusing.
> 

Yeah, dumb idea on my part. Leaving the policy decision for cache
timeouts in userland is probably the best thing. I think the only
reason we set this in kernel for the legacy upcall is that the keys get
instantiated there too and the legacy upcall format doesn't contain a
timeout that we can use. In principle that code should go away
eventually...

I think your patch looks fine and you can add my Reviewed-by: if you
like...

> >> 
> >> Finally, the key LRU discard patch: http://lkml.org/lkml/2012/3/28/144
> >> looks promising for managing key quotas.  But it only seems to be
> >> invoked when a key is linked into a destination keyring. fs/nfs/idmap.c
> >> uses a call to security/keys/request_key which by default provides an
> >> NULL dest_keyring. Might consider changing the request_key call in nfs/idmap.c
> >> to request_key_and_link (although I don't pretend to know all the
> >> implications of making such a change).
> 
> > Have you tested that? I thought these keys did end up in a keyring
> > (hence the whole override_creds/revert_creds song-and-dance). I haven't
> > looked closely at the LRU discard stuff though, so you may be correct
> > here...
> 
> Tested only in the sense that, after cranking down the root key quota to
> 20 or so, the LRU code does not seem to be working for NFS keys.  I
> should probably investigate that further.  I was hoping I would get
> a response of "yeah, we know it's not quite right" or "you haven't got
> things configured correctly".
> 

(cc'ing keyrings mailing list)

The keyring handling for this is a bit different than it would normally
be in userspace. Because we want to guard against someone "stuffing"
the keyring with bogus downcall info, we declare a private credential
and keyring in nfs_idmap_init_keyring.

My understanding (maybe incorrect) was that those keyrings are not
subject to quota enforcement and so they might not trigger the LRU
discard code. I may be wrong here though, the quota handling code in
the keys API is a bit difficult to follow...

-- 
Jeff Layton <jlayton@redhat.com>
