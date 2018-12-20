Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B016C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 18:26:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6E2F2218D9
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 18:26:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1545330398;
	bh=4tOl0NSbMoiRJqB+wMyMUTGy4zTplcKPHeBkm8okOiA=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=eQPp6+X1MuAyk0j0NpuKTlgh0EcENga61kaHAugc8gdVXrEHLl07Cw2KDM77QZaLt
	 jGYSMGzcmv8U5Bz8rdBUV3AGCAPNKrBUsUATzCMMRwHZRCnbrHqMjjj2HLCfKqqxTC
	 7/SfB9Snxym8LfwrddbiuN/CcPfB/gzjupDce1m0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732581AbeLTS0h (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 13:26:37 -0500
Received: from mail.kernel.org ([198.145.29.99]:35798 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731963AbeLTS0h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 13:26:37 -0500
Received: from vulkan.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 337DB218D9;
        Thu, 20 Dec 2018 18:26:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1545330396;
        bh=4tOl0NSbMoiRJqB+wMyMUTGy4zTplcKPHeBkm8okOiA=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=utoii8oPPDSw3vw2epdjpAy19da/fzjNX45p4pCp+nk1wJScV+tDpo5tCaA2oniYy
         12ULIZiALph3PLsum4MNBGluGpzVoAjhZoqSrDkrqS7F5nQ44n05kIGdhQKw0QG9w9
         CtVLx2wHOneoyFqirwTvgzOY+4sgZydEX4zRKLFQ=
Message-ID: <f1664df76f40994a848e58f8a4ea86ab8c855ff8.camel@kernel.org>
Subject: Re: [PATCH v2 3/3] nfsd: keep a tally of RECLAIM_COMPLETE
 operations when using nfsdcld
From:   Jeff Layton <jlayton@kernel.org>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
Date:   Thu, 20 Dec 2018 13:26:34 -0500
In-Reply-To: <20181220180536.GE6063@fieldses.org>
References: <20181218142926.27933-1-smayhew@redhat.com>
         <20181218142926.27933-4-smayhew@redhat.com>
         <20181219183600.GC28626@fieldses.org>
         <20181219220545.GS27213@coeurl.usersys.redhat.com>
         <20181219222147.GA31570@fieldses.org>
         <901adec26f1fd20259bd3e50d963f304b903d312.camel@kernel.org>
         <20181220180536.GE6063@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.3 (3.30.3-1.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 2018-12-20 at 13:05 -0500, J. Bruce Fields wrote:
> On Thu, Dec 20, 2018 at 12:29:43PM -0500, Jeff Layton wrote:
> > That wasn't my thinking here.
> > 
> > Suppose we have a client that holds some locks. Server reboots and we do
> > EXCHANGE_ID and start reclaiming, and eventually send a
> > RECLAIM_COMPLETE.
> > 
> > Now, there is a network partition and we lose contact with the server
> > for more than a lease period. The client record gets tossed out. Client
> > eventually reestablishes the connection before the grace period ends and
> > attempts to reclaim.
> > 
> > That reclaim should succeed, IMO, as there is no reason that it
> > shouldn't. Nothing can have claimed competing state since we're still in
> > the grace period.
> 
> That scenario requires a grace period longer than the lease period,
> which isn't impossible but sounds rare?  I guess you're thinking in the
> cluster case about the possibility of a second node failure extending
> the grace period.
> 

Isn't our grace period twice the lease period by default? I think we do
have to assume that it may take an entire lease period before the
client notices that the server has rebooted. If grace period == lease
period then you aren't leaving much time for reclaim to occur.

> Still, that's different from the case where the client explicitly
> destroys its own state.  That could happen in less than a lease period
> and in that case there won't be a reclaim.  I think that case could
> happen if a client rebooted quickly or maybe just unmounted.
> 
> Hm.
> 

True. You're right that we don't want to delay lifting the grace period
because we're waiting for clients that have unmounted and aren't coming
back. Unfortunately, it's difficult to distinguish the two cases. Could
we just decrement the counter when we're tearing down a clientid
because of lease expiration and not on DESTROY_CLIENT?

-- 
Jeff Layton <jlayton@kernel.org>

