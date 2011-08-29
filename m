Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754887Ab1H2VkD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 17:40:03 -0400
Date: Mon, 29 Aug 2011 14:37:51 -0700 (PDT)
Message-Id: <20110829.143751.1153162956919885670.davem@davemloft.net>
To: Trond.Myklebust@netapp.com
Cc: joe@perches.com, bfields@fieldses.org, neilb@suse.de,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
From: David Miller <davem@davemloft.net>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4EE9@SACMVEXC2-PRD.hq.netapp.com>
References: <cover.1314650069.git.joe@perches.com>
	<8a6378b3fef105983db001fb720c84b669491439.1314650069.git.joe@perches.com>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4EE9@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Date: Mon, 29 Aug 2011 14:36:17 -0700

> Big NACK...
> 
> By whose standard are those "not useful"?

By mine, that's for sure.  It's duplicating something that the allocation
layers are already going to print.
