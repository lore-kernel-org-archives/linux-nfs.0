Return-Path: <SRS0=QvV7=PG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7ACAC43612
	for <linux-nfs@archiver.kernel.org>; Sat, 29 Dec 2018 06:19:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 768BB217F9
	for <linux-nfs@archiver.kernel.org>; Sat, 29 Dec 2018 06:19:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728749AbeL2GTj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 29 Dec 2018 01:19:39 -0500
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:57844 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1728681AbeL2GTj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Dec 2018 01:19:39 -0500
X-IronPort-AV: E=Sophos;i="5.56,412,1539640800"; 
   d="scan'208";a="362048899"
Received: from abo-91-111-68.mrs.modulonet.fr (HELO hadrien) ([85.68.111.91])
  by mail2-relais-roc.national.inria.fr with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Dec 2018 07:19:35 +0100
Date:   Sat, 29 Dec 2018 07:19:35 +0100 (CET)
From:   Julia Lawall <julia.lawall@lip6.fr>
X-X-Sender: jll@hadrien
To:     "Darrick J. Wong" <darrick.wong@oracle.com>
cc:     Dan Carpenter <dan.carpenter@oracle.com>,
        Tom Psyborg <pozega.tomislav@gmail.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        kernel-janitors@vger.kernel.org, dmaengine@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Dan Williams <dan.j.williams@intel.com>,
        linux-scsi@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org,
        Stefano Stabellini <sstabellini@kernel.org>,
        xen-devel@lists.xenproject.org, linux-wireless@vger.kernel.org
Subject: Re: [PATCH 00/20] drop useless LIST_HEAD
In-Reply-To: <20181229052504.GA16315@magnolia>
Message-ID: <alpine.DEB.2.21.1812290717010.2673@hadrien>
References: <1545555435-24576-1-git-send-email-Julia.Lawall@lip6.fr> <CAKR_QVJefW1vxYb7-qiU8=0YdbFghYo15SK2eGjOC-dntRfyYA@mail.gmail.com> <alpine.DEB.2.21.1812232304130.2940@hadrien> <CAKR_QVLeZBL43W4x1mzcfcakSZyyh9L81vgUMxfnSccKawEfdg@mail.gmail.com>
 <20181227134055.GA2272@kadam> <20181229052504.GA16315@magnolia>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On Fri, 28 Dec 2018, Darrick J. Wong wrote:

> On Thu, Dec 27, 2018 at 04:40:55PM +0300, Dan Carpenter wrote:
> > On Tue, Dec 25, 2018 at 11:12:20PM +0100, Tom Psyborg wrote:
> > > there was discussion about this just some days ago. CC 4-5 lists is
> > > more than enough
> > >
> >
> > I don't know who you were discussing this with...
> >
> > You should CC the 0th patch to all the mailinglists.  That much is a
> > clear rule.
> >
> > For the rest, Julia's position is the more conservative one.  I was in
> > a conversation in RL and they were like, "CC everyone for all the
> > patches".  It depends on the context, of course.  If the patches are
> > dependent on each other then you *have* to CC everyone for everything.
>
> Agreed.  Ms. Lawall, sending "Cover letter + all relevant XFS patches"
> (as you did) was exactly the right thing for us xfs types. :)
>
> For that matter, we prefer to receive through linux-xfs more patches
> than necessary (one can send the entire series if one is unsure) than to
> go wanting for more context.

Thanks for the confirmation.  I was planning to ignore the 4-5 advice,
because there is no way in this case to make a meaningful 4-5 list
suggestion - it's either all or nothing.  But 20 patches at once is
perhaps a lot as well.  In this case, I just wanted to get rid of the
whole issue at once.

julia
