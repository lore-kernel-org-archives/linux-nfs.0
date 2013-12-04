Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga01-in.huawei.com ([119.145.14.64]:7753 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754721Ab3LDBA5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Dec 2013 20:00:57 -0500
Date: Wed, 4 Dec 2013 08:55:57 +0800
From: Minlan Wang <wangminlan@huawei.com>
To: Jeff Layton <jlayton@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: 3.12-rc2 nfsd oops in nfsd_cache_lookup
Message-ID: <20131204005557.GA18253@f18.localdomain>
References: <20131201102954.GA26976@infradead.org>
 <20131202122219.043174d6@tlielax.poochiereds.net>
 <20131202172547.GA5211@infradead.org>
 <20131203033342.GA8877@f18.localdomain>
 <20131203055938.582db322@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <20131203055938.582db322@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 03, 2013 at 05:59:38AM -0500, Jeff Layton wrote:
> 
> Actually, it's pretty unlikely that this would get pruned here.
> lru_put_end updates the timestamp on the entry, so the
> prune_cache_entries run would have to take more than 120s and prune
> everything off of the list.
> 
> The real bug is that we can later find the entry in the hash that we
> intend to reuse and then free that cache entry. The safe thing to do
> here is to just unhash the entry that we intend to use so that it can't
> be found or pruned.
> 
> I sent a patch that should fix this the correct way:
> 
>     [PATCH] nfsd: when reusing an existing repcache entry, unhash it first
> 
Yes, you are right. Thanks.
