Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34230 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933075AbcCQQpt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2016 12:45:49 -0400
Date: Thu, 17 Mar 2016 09:45:46 -0700
From: Tejun Heo <tj@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Amitoj Kaur Chawla <amitoj1606@gmail.com>,
        kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>,
        Johannes Berg <johannes@sipsolutions.net>,
        Eva Rachel Retuya <eraretuya@gmail.com>,
        Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        linux-wireless@vger.kernel.org
Subject: [RFD] workqueue: WQ_MEM_RECLAIM usage in network drivers
Message-ID: <20160317164546.GT21104@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Years ago, workqueue got reimplemented to use common worker pools
across different workqueues and a new set of more expressive workqueue
creation APIs, alloc_*workqueue() were introduced.  The old
create_*workqueue() became simple wrappers around alloc_*workqueue()
with the most conservative parameters.  The plan has always been to
examine each usage and convert to the new interface with parameters
actually required for the use case.

One important flag to decide upon is WQ_MEM_RECLAIM, which declares
that the workqueue may be depended upon during memory reclaim and thus
must be able to make forward-progress even when further memory can't
be allocated without reclaiming some.  Of the network drivers which
already use alloc_*workqueue() interface, some specify this flag and
I'm wondering what the guidelines should be here.

* Are network devices expected to be able to serve as a part of
  storage stack which is depended upon for memory reclamation?

* If so, are all the pieces in place for that to work for all (or at
  least most) network devices?  If it's only for a subset of NICs, how
  can one tell whether a given driver needs forward progress guarantee
  or not?

* I assume that wireless drivers aren't and can't be used in this
  fashion.  Is that a correction assumption?

Thanks.

-- 
tejun
