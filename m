Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:60584 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbaJRKKi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Oct 2014 06:10:38 -0400
Received: by mail-qc0-f171.google.com with SMTP id i17so1766095qcy.30
        for <linux-nfs@vger.kernel.org>; Sat, 18 Oct 2014 03:10:37 -0700 (PDT)
Date: Sat, 18 Oct 2014 06:10:33 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Colin Hudler <chudler@cs.uchicago.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: when rpc.mountd flushes auth.unix.gid
Message-ID: <20141018061033.07cb8de7@tlielax.poochiereds.net>
In-Reply-To: <60F78F70-72B4-41CA-8B13-3C7D607569E0@primarydata.com>
References: <54412AC6.7070000@cs.uchicago.edu>
	<20141017170646.1700320e@tlielax.poochiereds.net>
	<689A9C05-09FC-4EDB-B607-CF59E9943FE4@primarydata.com>
	<20141017193739.375320cb@tlielax.poochiereds.net>
	<60F78F70-72B4-41CA-8B13-3C7D607569E0@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 17 Oct 2014 21:21:18 -0500
Tom Haynes <thomas.haynes@primarydata.com> wrote:

> 
> On Oct 17, 2014, at 6:37 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> 
> > On Fri, 17 Oct 2014 17:24:14 -0500
> > Tom Haynes <thomas.haynes@primarydata.com> wrote:
> > 
> >> 
> >> 
> >> 
> >>> On Oct 17, 2014, at 4:06 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> >>> 
> >>> On Fri, 17 Oct 2014 09:42:14 -0500
> >>> Colin Hudler <chudler@cs.uchicago.edu> wrote:
> >>> 
> >>>> We have a few hundred computers mounting an NFS server in a typical 
> >>>> LDAP-based users (nss) setup. We frequently add and remove exports and 
> >>>> use exportfs -r to update etab. Every time we do so, the clients report 
> >>>> "NFS server not responding" and start backing off their requests. After 
> >>>> a painful 3-5 minutes, they recover and life is normal again.
> >>>> 
> >>>> We discovered that when the rpc.mountd cache flushing occurs, our NIS 
> >>>> system is overwhelmed with grouplist requests and this obviously blocks 
> >>>> things. We are working on that problem separately, and I admit this to 
> >>>> be a weakness in our setup. My question is simple.
> >>>> 
> >>>> Why does it flush auth.unix.gid when the etab changed? I think it makes 
> >>>> unnecessary work for rpc.mountd because the gids are unlikely to have 
> >>>> changed, and they already have a reasonable expiration policy.
> >>> 
> >>> Most likely because no one really cared until now.
> >>> 
> >>> When exports change, cache_flush() is called and that function flushes
> >>> out all of the kernel caches.
> >>> 
> >>> I expect that could be made to do something a bit more granular, but
> >>> you may need to do some archaeology in mountd/exportfs (and the kernel)
> >>> to ensure that you're not missing anything.
> >>> 
> >> 
> >> One thing would be to not remove the exports which are going to be added back in.
> >> 
> >> The catch here is that you have to account for new entries which need to be added.
> >> 
> >> 
> > 
> > I'm not sure that flushing the uid or gid caches is really necessary on
> > an exports change at all. I don't think we expect that info to change.
> 
> Is there a manual way to flush these caches?
> 
> Bump down the default TTL?
> 
> 

The manual way is to write to /proc/net/rpc/*/flush (which is what
cache_flush() in nfs-utils does). The comments over it say:

/* flush the kNFSd caches.
 * Set the flush time to the mtime of _PATH_ETAB or
 * if force, to now.
 * the caches to flush are:
 *  auth.unix.ip nfsd.export nfsd.fh
 */

...but it looks like auth.unix.gid was added in 2007 and the
comment wasn't updated.

> > 
> > In practical terms, we might be able to change exportfs to just flush
> > the nfsd.fh and nfsd.export caches instead of a full cache_flush() ?
> > 
> > -- 
> > Jeff Layton <jlayton@poochiereds.net>
> 


-- 
Jeff Layton <jlayton@poochiereds.net>
