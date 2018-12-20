Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9C07C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 16:36:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 949A421773
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 16:36:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730251AbeLTQgx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 11:36:53 -0500
Received: from mx1.redhat.com ([209.132.183.28]:43426 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726604AbeLTQgx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 11:36:53 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 868E33D960;
        Thu, 20 Dec 2018 16:36:53 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 5C2E74A7;
        Thu, 20 Dec 2018 16:36:53 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id EB0032078D; Thu, 20 Dec 2018 11:36:52 -0500 (EST)
Date:   Thu, 20 Dec 2018 11:36:52 -0500
From:   Scott Mayhew <smayhew@redhat.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/3] nfsd: keep a tally of RECLAIM_COMPLETE operations
 when using nfsdcld
Message-ID: <20181220163652.GU27213@coeurl.usersys.redhat.com>
References: <20181218142926.27933-1-smayhew@redhat.com>
 <20181218142926.27933-4-smayhew@redhat.com>
 <20181219183600.GC28626@fieldses.org>
 <20181219220545.GS27213@coeurl.usersys.redhat.com>
 <20181219222147.GA31570@fieldses.org>
 <20181219224317.GB31570@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219224317.GB31570@fieldses.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 20 Dec 2018 16:36:53 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 19 Dec 2018, J. Bruce Fields wrote:

> On Wed, Dec 19, 2018 at 05:21:47PM -0500, J. Bruce Fields wrote:
> > On Wed, Dec 19, 2018 at 05:05:45PM -0500, Scott Mayhew wrote:
> > > What if a client sends a RECLAIM_COMPLETE, then reboots and sends an
> > > EXCHANGE_ID, CREATE_SESSION, and RECLAIM_COMPLETE while the server is
> > > still in grace?  The count would be too high then and the server could
> > > exit grace before all the clients have reclaimed.  I actually added
> > > that at Jeff's suggestion because he was seeing it with nfs-ganesha.  
> > 
> > Oh boy.
> > 
> > (Thinks.)
> > 
> > Once it issues a DESTROY_CLIENTID or an EXCHANGE_ID that removes the
> > previous client instance's state, it's got no locks to reclaim any more.
> > (It can't have gotten any *new* ones, since we're still in the grace
> > period.)
> > 
> > It's effectively a brand new client.  Only reclaiming clients should
> > bump that counter.
> > 
> > We certainly shouldn't be waiting for it to RECLAIM_COMPLETE to end the
> > grace period, that client just doesn't matter any more.
> 
> Actually, once the client's destroyed, it shouldn't matter whether the
> previous incarnation of the client reclaimed or not.  It's never going
> to reclaim now....  So expire_client should probably just be removing
> the client from the table of reclaimable clients at the same time that
> it removes its stable storage record.

Okay, come to think of it, if we're in grace then nfsdcld should be
removing the client record from both the current and recovery epoch's db
tables too...
> 
> --b.
