Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC9DEC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 17:32:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8D09F218D3
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 17:32:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1545327144;
	bh=/Fki/5GYCCV/SGNEsm8yQNspiP12x11WmEsj6624eZ0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=UweIn+BGjpF2DeWFG/SOvldChPs5YDsMPvYJMJxftgqKhxuYRdScSGVjFeTRKkMvC
	 NjSFwb+bMwmhcsR3fDIfN9RmkOcHL8Cr4wIro6+zSe2kMF0oFlRTpEjKJmb+46xoHw
	 Ksv6XP1ZM9jLUvIybCiavUTIR/gg9q9SOlIyyxZY=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387643AbeLTRcX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 12:32:23 -0500
Received: from mail.kernel.org ([198.145.29.99]:37162 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387479AbeLTRcX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 12:32:23 -0500
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 9F5EB2186A;
        Thu, 20 Dec 2018 17:32:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1545327143;
        bh=/Fki/5GYCCV/SGNEsm8yQNspiP12x11WmEsj6624eZ0=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=08P/6Qria61iwb3ctcyXTUOGE49uSWblcf2dzp5Zm3Hp7M1lJGHJqa83XYeelUrPa
         BrZdKbRh+NAPJSYsPJW71I5uSilJZp2n8Dik7tcL5bRZWanV6Fxv5sp/TQv5vGWi2C
         SF+TWq19ETkdaj2oRSj2Sf9DaBEgBMOGZmHdFvZI=
Message-ID: <6c8dd30fd6ace433d43f4892afd18af1ef6bc899.camel@kernel.org>
Subject: Re: [PATCH v2 3/3] nfsd: keep a tally of RECLAIM_COMPLETE
 operations when using nfsdcld
From:   Jeff Layton <jlayton@kernel.org>
To:     Scott Mayhew <smayhew@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org
Date:   Thu, 20 Dec 2018 12:32:21 -0500
In-Reply-To: <20181220163652.GU27213@coeurl.usersys.redhat.com>
References: <20181218142926.27933-1-smayhew@redhat.com>
         <20181218142926.27933-4-smayhew@redhat.com>
         <20181219183600.GC28626@fieldses.org>
         <20181219220545.GS27213@coeurl.usersys.redhat.com>
         <20181219222147.GA31570@fieldses.org> <20181219224317.GB31570@fieldses.org>
         <20181220163652.GU27213@coeurl.usersys.redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.3 (3.30.3-1.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 2018-12-20 at 11:36 -0500, Scott Mayhew wrote:
> On Wed, 19 Dec 2018, J. Bruce Fields wrote:
> 
> > On Wed, Dec 19, 2018 at 05:21:47PM -0500, J. Bruce Fields wrote:
> > > On Wed, Dec 19, 2018 at 05:05:45PM -0500, Scott Mayhew wrote:
> > > > What if a client sends a RECLAIM_COMPLETE, then reboots and sends an
> > > > EXCHANGE_ID, CREATE_SESSION, and RECLAIM_COMPLETE while the server is
> > > > still in grace?  The count would be too high then and the server could
> > > > exit grace before all the clients have reclaimed.  I actually added
> > > > that at Jeff's suggestion because he was seeing it with nfs-ganesha.  
> > > 
> > > Oh boy.
> > > 
> > > (Thinks.)
> > > 
> > > Once it issues a DESTROY_CLIENTID or an EXCHANGE_ID that removes the
> > > previous client instance's state, it's got no locks to reclaim any more.
> > > (It can't have gotten any *new* ones, since we're still in the grace
> > > period.)
> > > 
> > > It's effectively a brand new client.  Only reclaiming clients should
> > > bump that counter.
> > > 
> > > We certainly shouldn't be waiting for it to RECLAIM_COMPLETE to end the
> > > grace period, that client just doesn't matter any more.
> > 
> > Actually, once the client's destroyed, it shouldn't matter whether the
> > previous incarnation of the client reclaimed or not.  It's never going
> > to reclaim now....  So expire_client should probably just be removing
> > the client from the table of reclaimable clients at the same time that
> > it removes its stable storage record.
> 
> Okay, come to think of it, if we're in grace then nfsdcld should be
> removing the client record from both the current and recovery epoch's db
> tables too...

No!

The recovery table is a record of who held state at the end of the prior
epoch. That does not change just because the client went away during the
current epoch.

You should only ever alter the table for the epoch that you are in. Once
the grace period is lifted, you can delete the tables for any prior
epoch.

-- 
Jeff Layton <jlayton@kernel.org>

