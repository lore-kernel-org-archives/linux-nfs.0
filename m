Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF10BC04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 20:42:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7BE362081C
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 20:42:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BE362081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725875AbeLDUmg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 15:42:36 -0500
Received: from fieldses.org ([173.255.197.46]:49200 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725866AbeLDUmg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Dec 2018 15:42:36 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 1DDC21C22; Tue,  4 Dec 2018 15:42:36 -0500 (EST)
Date:   Tue, 4 Dec 2018 15:42:36 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     NeilBrown <neilb@suse.com>
Cc:     Vasily Averin <vvs@virtuozzo.com>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: Re: [PATCH 0/1] cache_head leak in sunrpc_cache_lookup()
Message-ID: <20181204204236.GE3903@fieldses.org>
References: <d6bac5b8-9ee9-289c-7e85-0d4b6f55c931@virtuozzo.com>
 <20181128233514.GC24160@fieldses.org>
 <87zhtso38v.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87zhtso38v.fsf@notabene.neil.brown.name>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 29, 2018 at 04:35:12PM +1100, NeilBrown wrote:
> On Wed, Nov 28 2018, J. Bruce Fields wrote:
> 
> > On Wed, Nov 28, 2018 at 11:45:46AM +0300, Vasily Averin wrote:
> >> Dear all, we have found memory leak on OpenVz7 node and believe it
> >> affects mainline too.
> >> 
> >> sunrpc_cache_lookup() removes exprired cache_head from hash, however
> >> if it waits for reply on submitted cache_request both of them can leak
> >> forever, nobody cleans unhashed cache_heads.
> >> 
> >> Originally we had claim on busy loop device of stopped container, that
> >> had executed nfs server inside.  Device was kept by mount that was
> >> detached from already destroyed mount namespace.  By using crash
> >> search we have found some structure with path struct related to our
> >> mount.  Finally we have found that it was alive svc_export struct used
> >> by to alive cache_request, however both of them pointed to already
> >> freed cache_detail.
> >> 
> >> We decided that cache_detail was correctly freed during destroy of net
> >> namespace, however svc_export with taken path struct, cache_request
> >> and some other structures seems was leaked forever.
> >> 
> >> This could  happen only if cache_head of svc_export was removed from
> >> hash on cache_detail before its destroy. Finally we have found that it
> >> could happen when sunrpc_cache_lookup() removes expired cache_head
> >> from hash.
> >> 
> >> Usually it works correctly and cache_put(freeme) frees expired
> >> cache_head.  However in our case cache_head have an extra reference
> >> counter from stalled cache_request.  Becasue of cache_head was removed
> >> from hash of cache_detail it cannot be found in cache_clean() and its
> >> cache_request cannot be freed in cache_dequeue(). Memory leaks
> >> forever, exactly like we observed.
> >> 
> >> After may attempts we have reproduced this situation on OpenVz7
> >> kernel, however our reproducer is quite long and complex.
> >> Unfortunately we still did not reproduced this problem on mainline
> >> kernel and did not validated the patch yet.
> >> 
> >> It would be great if someone advised us some simple way to trigger
> >> described scenario.
> >
> > I think you should be able to produce hung upcalls by flushing the cache
> > (exportfs -f), then stopping mountd, then trying to access the
> > filesystem from a client.  Does that help?
> >
> >> We are not sure that our patch is correct, please let us know if our
> >> analyze missed something.
> >
> > It looks OK to me, but it would be helpful to have Neil's review too.
> 
> Yes, it makes sense to me.
>  Reviewed-by: NeilBrown <neilb@suse.com>

OK, applied for 4.21.--b.
