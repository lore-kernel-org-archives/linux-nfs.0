Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8969BC43444
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 18:05:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6840E217D9
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 18:05:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731288AbeLTSFh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 13:05:37 -0500
Received: from fieldses.org ([173.255.197.46]:48740 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388514AbeLTSFh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 13:05:37 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 9596F1C96; Thu, 20 Dec 2018 13:05:36 -0500 (EST)
Date:   Thu, 20 Dec 2018 13:05:36 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/3] nfsd: keep a tally of RECLAIM_COMPLETE operations
 when using nfsdcld
Message-ID: <20181220180536.GE6063@fieldses.org>
References: <20181218142926.27933-1-smayhew@redhat.com>
 <20181218142926.27933-4-smayhew@redhat.com>
 <20181219183600.GC28626@fieldses.org>
 <20181219220545.GS27213@coeurl.usersys.redhat.com>
 <20181219222147.GA31570@fieldses.org>
 <901adec26f1fd20259bd3e50d963f304b903d312.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <901adec26f1fd20259bd3e50d963f304b903d312.camel@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Dec 20, 2018 at 12:29:43PM -0500, Jeff Layton wrote:
> That wasn't my thinking here.
> 
> Suppose we have a client that holds some locks. Server reboots and we do
> EXCHANGE_ID and start reclaiming, and eventually send a
> RECLAIM_COMPLETE.
> 
> Now, there is a network partition and we lose contact with the server
> for more than a lease period. The client record gets tossed out. Client
> eventually reestablishes the connection before the grace period ends and
> attempts to reclaim.
> 
> That reclaim should succeed, IMO, as there is no reason that it
> shouldn't. Nothing can have claimed competing state since we're still in
> the grace period.

That scenario requires a grace period longer than the lease period,
which isn't impossible but sounds rare?  I guess you're thinking in the
cluster case about the possibility of a second node failure extending
the grace period.

Still, that's different from the case where the client explicitly
destroys its own state.  That could happen in less than a lease period
and in that case there won't be a reclaim.  I think that case could
happen if a client rebooted quickly or maybe just unmounted.

Hm.

--b.
