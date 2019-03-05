Return-Path: <SRS0=HPA/=RI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F51EC43381
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 21:42:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 47A6920652
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 21:42:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727417AbfCEVmM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Mar 2019 16:42:12 -0500
Received: from fieldses.org ([173.255.197.46]:40554 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726214AbfCEVmM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Mar 2019 16:42:12 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 26C3C77E; Tue,  5 Mar 2019 16:42:12 -0500 (EST)
Date:   Tue, 5 Mar 2019 16:42:12 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     NeilBrown <neilb@suse.com>
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix memory corruption caused by readdir
Message-ID: <20190305214212.GC27437@fieldses.org>
References: <87lg1vs5eh.fsf@notabene.neil.brown.name>
 <20190304164725.GE13690@fieldses.org>
 <877ederyjm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877ederyjm.fsf@notabene.neil.brown.name>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Mar 05, 2019 at 10:48:45AM +1100, NeilBrown wrote:
> On Mon, Mar 04 2019, J. Bruce Fields wrote:
> 
> > On Mon, Mar 04, 2019 at 02:08:22PM +1100, NeilBrown wrote:
> >> (Note that the commit hash in the Fixes tag is from the 'history'
> >>  tree - this bug predates git).
> >> Fixes: eb229d253e6c ("[PATCH] kNFSd: fix two xdr-encode bugs for readdirplus reply")
> >
> > It'd be nice to provide a URL for that.  The one I originally cloned one
> > seems to have disappeared.
> 
> Fixes-URL: https://git.kernel.org/pub/scm/linux/kernel/git/history/history.git/commit/?id=eb229d253e6c
> 
> Though on reflection, that didn't introduce the bug, it just failed to
> fix it properly.  It should be:
> 
> Fixes: 0b1d57cf7654 ("[PATCH] kNFSd: Fix nfs3 dentry encoding")
> Fixes-URL: https://git.kernel.org/pub/scm/linux/kernel/git/history/history.git/commit/?id=0b1d57cf7654

Oh, so we can blame Olaf.  Even better.

> > And how did it go undetected so long, and what caused it to surface just
> > now?
> 
> I suspect two different things need to come together to trigger the bug.
> 1/ a directory needs to have filename lengths which cause the xdr
>    encoding of the readdirplus reply to place the offset across a page
>    boundary.
>    A typical entry is around 200 bytes, or 50 quads, so there should be
>    a 1:50 chance of hitting that, assuming name lengths are evenly
>    distributed (which they aren't).
>    In the case which triggered the bug, all file names were 43 bytes,
>    all filehandles 28 bytes. This means 192 bytes per entry.
>    21 entries fit in a page leaving 64 bytes.  This puts the cookie
>    on the page boundary.
> 
> 2/ The *next* entry after the one that crosses the page boundary doesn't
>    fit.  In the cases which triggered, the requested size was 0x1110
>    (4368).
>    That is enough room for 21 entries, but not for 22.
> 
> So presumably the client doesn't run Linux - which always asks
> for 4096 bytes of directory entry (from a Linux server).
> I have no idea what clients the customer was using, but these clients
> seem to have a fairly good chance of triggering the bug (when configured
> like the customer configured them - maybe).

Thanks for the explanation!

> > I once thought about converting this over to the xdr_stream api that
> > NFSv4 uses to hide the page-crossing logic now.  But I think it's better
> > to leave it alone.
> 
> I agree - the code isn't being actively developed, so stability wins
> over elegance.
> 
> 
> BTW, the readdir (non-plus) code doesn't really need fixing.
> nfs3svc_decode_readdirargs() caps the ->count at PAGE_SIZE, so the cookie
> can never cross pages. nfs3svc_decode_readdirplusargs() caps it
> at max_blocksize.  So if you feel like leaving that part of the change
> out, I probably wouldn't complain.

Eh, makes sense to me to fix it.

--b.
