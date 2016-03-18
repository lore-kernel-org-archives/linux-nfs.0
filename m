Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:35692 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbcCRUq0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Mar 2016 16:46:26 -0400
Date: Fri, 18 Mar 2016 16:46:23 -0400
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Amitoj Kaur Chawla <amitoj1606@gmail.com>, kernel-team@fb.com,
        Johannes Weiner <hannes@cmpxchg.org>,
        Johannes Berg <johannes@sipsolutions.net>,
        Eva Rachel Retuya <eraretuya@gmail.com>,
        Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        linux-wireless@vger.kernel.org
Subject: Re: [RFD] workqueue: WQ_MEM_RECLAIM usage in network drivers
Message-ID: <20160318204623.GM20028@mtj.duckdns.org>
References: <20160317164546.GT21104@mtj.duckdns.org>
 <20160317213216.731d1fcc@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160317213216.731d1fcc@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Jeff.

On Thu, Mar 17, 2016 at 09:32:16PM -0400, Jeff Layton wrote:
> > * Are network devices expected to be able to serve as a part of
> >   storage stack which is depended upon for memory reclamation?
> 
> I think they should be. Cached NFS pages can consume a lot of memory,
> and flushing them generally takes network device access.

But does that actually work?  It's pointless to add WQ_MEM_RECLAIM to
workqueues unless all other things are also guaranteed to make forward
progress regardless of memory pressure.

> > * If so, are all the pieces in place for that to work for all (or at
> >   least most) network devices?  If it's only for a subset of NICs, how
> >   can one tell whether a given driver needs forward progress guarantee
> >   or not?
> > 
> > * I assume that wireless drivers aren't and can't be used in this
> >   fashion.  Is that a correction assumption?
> > 
> 
> People do mount NFS over wireless interfaces. It's not terribly common
> though, in my experience.

Ditto, I'm very skeptical that this actually works in practice and
people expect and depend on it.  I don't follow wireless development
closely but haven't heard anyone talking about reserving memory pools
or people complaining about wireless being the cause of OOM.

So, I really want to avoid spraying WQ_MEM_RECLAIM if it doesn't serve
actual purposes.  It's wasteful, sets bad precedences and confuses
future readers.

Thanks.

-- 
tejun
