Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:43564 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335AbaJQXhq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2014 19:37:46 -0400
Received: by mail-qg0-f47.google.com with SMTP id i50so1268459qgf.20
        for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2014 16:37:45 -0700 (PDT)
Date: Fri, 17 Oct 2014 19:37:39 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Colin Hudler <chudler@cs.uchicago.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: when rpc.mountd flushes auth.unix.gid
Message-ID: <20141017193739.375320cb@tlielax.poochiereds.net>
In-Reply-To: <689A9C05-09FC-4EDB-B607-CF59E9943FE4@primarydata.com>
References: <54412AC6.7070000@cs.uchicago.edu>
	<20141017170646.1700320e@tlielax.poochiereds.net>
	<689A9C05-09FC-4EDB-B607-CF59E9943FE4@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 17 Oct 2014 17:24:14 -0500
Tom Haynes <thomas.haynes@primarydata.com> wrote:

> 
> 
> 
> > On Oct 17, 2014, at 4:06 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> > 
> > On Fri, 17 Oct 2014 09:42:14 -0500
> > Colin Hudler <chudler@cs.uchicago.edu> wrote:
> > 
> >> We have a few hundred computers mounting an NFS server in a typical 
> >> LDAP-based users (nss) setup. We frequently add and remove exports and 
> >> use exportfs -r to update etab. Every time we do so, the clients report 
> >> "NFS server not responding" and start backing off their requests. After 
> >> a painful 3-5 minutes, they recover and life is normal again.
> >> 
> >> We discovered that when the rpc.mountd cache flushing occurs, our NIS 
> >> system is overwhelmed with grouplist requests and this obviously blocks 
> >> things. We are working on that problem separately, and I admit this to 
> >> be a weakness in our setup. My question is simple.
> >> 
> >> Why does it flush auth.unix.gid when the etab changed? I think it makes 
> >> unnecessary work for rpc.mountd because the gids are unlikely to have 
> >> changed, and they already have a reasonable expiration policy.
> > 
> > Most likely because no one really cared until now.
> > 
> > When exports change, cache_flush() is called and that function flushes
> > out all of the kernel caches.
> > 
> > I expect that could be made to do something a bit more granular, but
> > you may need to do some archaeology in mountd/exportfs (and the kernel)
> > to ensure that you're not missing anything.
> > 
> 
> One thing would be to not remove the exports which are going to be added back in.
> 
> The catch here is that you have to account for new entries which need to be added.
> 
> 

I'm not sure that flushing the uid or gid caches is really necessary on
an exports change at all. I don't think we expect that info to change.

In practical terms, we might be able to change exportfs to just flush
the nfsd.fh and nfsd.export caches instead of a full cache_flush() ?

-- 
Jeff Layton <jlayton@poochiereds.net>
