Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37398C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 22:43:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0707320869
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 22:43:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727644AbeLSWnS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 17:43:18 -0500
Received: from fieldses.org ([173.255.197.46]:47398 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726716AbeLSWnS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 17:43:18 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id AABD0492; Wed, 19 Dec 2018 17:43:17 -0500 (EST)
Date:   Wed, 19 Dec 2018 17:43:17 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/3] nfsd: keep a tally of RECLAIM_COMPLETE operations
 when using nfsdcld
Message-ID: <20181219224317.GB31570@fieldses.org>
References: <20181218142926.27933-1-smayhew@redhat.com>
 <20181218142926.27933-4-smayhew@redhat.com>
 <20181219183600.GC28626@fieldses.org>
 <20181219220545.GS27213@coeurl.usersys.redhat.com>
 <20181219222147.GA31570@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219222147.GA31570@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 19, 2018 at 05:21:47PM -0500, J. Bruce Fields wrote:
> On Wed, Dec 19, 2018 at 05:05:45PM -0500, Scott Mayhew wrote:
> > What if a client sends a RECLAIM_COMPLETE, then reboots and sends an
> > EXCHANGE_ID, CREATE_SESSION, and RECLAIM_COMPLETE while the server is
> > still in grace?  The count would be too high then and the server could
> > exit grace before all the clients have reclaimed.  I actually added
> > that at Jeff's suggestion because he was seeing it with nfs-ganesha.  
> 
> Oh boy.
> 
> (Thinks.)
> 
> Once it issues a DESTROY_CLIENTID or an EXCHANGE_ID that removes the
> previous client instance's state, it's got no locks to reclaim any more.
> (It can't have gotten any *new* ones, since we're still in the grace
> period.)
> 
> It's effectively a brand new client.  Only reclaiming clients should
> bump that counter.
> 
> We certainly shouldn't be waiting for it to RECLAIM_COMPLETE to end the
> grace period, that client just doesn't matter any more.

Actually, once the client's destroyed, it shouldn't matter whether the
previous incarnation of the client reclaimed or not.  It's never going
to reclaim now....  So expire_client should probably just be removing
the client from the table of reclaimable clients at the same time that
it removes its stable storage record.

--b.
