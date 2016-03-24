Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38542 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756228AbcCXOWy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2016 10:22:54 -0400
Message-ID: <1458829358.9304.2.camel@sipsolutions.net>
Subject: Re: [RFD] workqueue: WQ_MEM_RECLAIM usage in network drivers
From: Johannes Berg <johannes@sipsolutions.net>
To: Tejun Heo <tj@kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Amitoj Kaur Chawla <amitoj1606@gmail.com>, kernel-team@fb.com,
        Johannes Weiner <hannes@cmpxchg.org>,
        Eva Rachel Retuya <eraretuya@gmail.com>,
        Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        linux-wireless@vger.kernel.org
Date: Thu, 24 Mar 2016 15:22:38 +0100
In-Reply-To: <20160320185507.GT20028@mtj.duckdns.org> (sfid-20160320_195510_233358_7162AE83)
References: <20160317164546.GT21104@mtj.duckdns.org>
	 <20160317213216.731d1fcc@synchrony.poochiereds.net>
	 <20160318204623.GM20028@mtj.duckdns.org>
	 <20160318212405.GA5192@fieldses.org>
	 <20160320185507.GT20028@mtj.duckdns.org>
	 (sfid-20160320_195510_233358_7162AE83)
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2016-03-20 at 14:55 -0400, Tejun Heo wrote:
> If everything else is working, I'd be happy to throw in
> WQ_MEM_RECLAIM but I really don't want to add it if it doesn't
> actually achieve the goal.  Can a wireless person chime in here?
> 

I think for many wireless devices the workqueue, like for iwldvm that
was just changed, isn't in the packet path and thus less relevant.

For some, like SDIO based chips, it's more likely to be in the packet
path, so it would make sense to keep it.

Of course there's always a possibility of getting disconnected and then
not being able to re-establish the connection in memory pressure, but
that's not something we can control/predict (the disconnection). Can of
course also happen with wired if somebody pulls out the cable, but it's
less reliant on memory allocations to get back to working there, I
guess :)

johannes
