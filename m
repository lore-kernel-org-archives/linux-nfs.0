Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:33478 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbcCRBcV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2016 21:32:21 -0400
Received: by mail-yw0-f171.google.com with SMTP id m126so98392823ywd.0
        for <linux-nfs@vger.kernel.org>; Thu, 17 Mar 2016 18:32:21 -0700 (PDT)
Date: Thu, 17 Mar 2016 21:32:16 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Tejun Heo <tj@kernel.org>
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
Message-ID: <20160317213216.731d1fcc@synchrony.poochiereds.net>
In-Reply-To: <20160317164546.GT21104@mtj.duckdns.org>
References: <20160317164546.GT21104@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 Mar 2016 09:45:46 -0700
Tejun Heo <tj@kernel.org> wrote:

> Hello,
> 
> Years ago, workqueue got reimplemented to use common worker pools
> across different workqueues and a new set of more expressive workqueue
> creation APIs, alloc_*workqueue() were introduced.  The old
> create_*workqueue() became simple wrappers around alloc_*workqueue()
> with the most conservative parameters.  The plan has always been to
> examine each usage and convert to the new interface with parameters
> actually required for the use case.
> 
> One important flag to decide upon is WQ_MEM_RECLAIM, which declares
> that the workqueue may be depended upon during memory reclaim and thus
> must be able to make forward-progress even when further memory can't
> be allocated without reclaiming some.  Of the network drivers which
> already use alloc_*workqueue() interface, some specify this flag and
> I'm wondering what the guidelines should be here.
> 
> * Are network devices expected to be able to serve as a part of
>   storage stack which is depended upon for memory reclamation?
> 

I think they should be. Cached NFS pages can consume a lot of memory,
and flushing them generally takes network device access.

> * If so, are all the pieces in place for that to work for all (or at
>   least most) network devices?  If it's only for a subset of NICs, how
>   can one tell whether a given driver needs forward progress guarantee
>   or not?
> 
> * I assume that wireless drivers aren't and can't be used in this
>   fashion.  Is that a correction assumption?
> 

People do mount NFS over wireless interfaces. It's not terribly common
though, in my experience.

-- 
Jeff Layton <jlayton@poochiereds.net>
