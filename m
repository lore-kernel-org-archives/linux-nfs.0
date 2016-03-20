Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35500 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753642AbcCTSzK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Mar 2016 14:55:10 -0400
Date: Sun, 20 Mar 2016 14:55:07 -0400
From: Tejun Heo <tj@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Amitoj Kaur Chawla <amitoj1606@gmail.com>, kernel-team@fb.com,
        Johannes Weiner <hannes@cmpxchg.org>,
        Johannes Berg <johannes@sipsolutions.net>,
        Eva Rachel Retuya <eraretuya@gmail.com>,
        Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        linux-wireless@vger.kernel.org
Subject: Re: [RFD] workqueue: WQ_MEM_RECLAIM usage in network drivers
Message-ID: <20160320185507.GT20028@mtj.duckdns.org>
References: <20160317164546.GT21104@mtj.duckdns.org>
 <20160317213216.731d1fcc@synchrony.poochiereds.net>
 <20160318204623.GM20028@mtj.duckdns.org>
 <20160318212405.GA5192@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160318212405.GA5192@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Fri, Mar 18, 2016 at 05:24:05PM -0400, J. Bruce Fields wrote:
> > But does that actually work?  It's pointless to add WQ_MEM_RECLAIM to
> > workqueues unless all other things are also guaranteed to make forward
> > progress regardless of memory pressure.
> 
> It's supposed to work.
> 
> Also note there was a bunch of work done to allow swap on NFS: see
> a564b8f0 "nfs: enable swap on NFS".

Alright, WQ_MEM_RECLAIM for ethernet devices, then.

> I use NFS mounts over wifi at home.  I may just be odd.  I seem to
> recall some bug reports about suspend vs. NFS--were those also on
> laptops using NFS?
> 
> I wonder if home media centers might do writes over wifi to network
> storage?
> 
> Googling for "nfs wifi" turns up lots of individuals doing this.
> 
> My first impulse is to say that it's probably not perfect but that we
> shouldn't make it worse.

If everything else is working, I'd be happy to throw in WQ_MEM_RECLAIM
but I really don't want to add it if it doesn't actually achieve the
goal.  Can a wireless person chime in here?

Thanks.

-- 
tejun
