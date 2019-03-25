Return-Path: <SRS0=29O7=R4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04543C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 22:21:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C793720811
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 22:21:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729664AbfCYWVJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Mar 2019 18:21:09 -0400
Received: from fieldses.org ([173.255.197.46]:56004 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729610AbfCYWVJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Mar 2019 18:21:09 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id C29E21CE6; Mon, 25 Mar 2019 18:21:08 -0400 (EDT)
Date:   Mon, 25 Mar 2019 18:21:08 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     NeilBrown <neilb@suse.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc/cache: handle missing listeners better.
Message-ID: <20190325222108.GB22644@fieldses.org>
References: <87pnqj64br.fsf@notabene.neil.brown.name>
 <20190322165338.GB7692@fieldses.org>
 <87bm225ymv.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bm225ymv.fsf@notabene.neil.brown.name>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Mar 23, 2019 at 09:32:08AM +1100, NeilBrown wrote:
> On Fri, Mar 22 2019, J. Bruce Fields wrote:
> > I've gotten complaints about the same thing and said "well, in
> > retrospect we shouldn't have designed the interface this way, but we
> > did, so just stop opening those files".
> 
> As the fool who actually "designed" this,

Pretty sure I was there too and had my chance to object.  In any case,
hope you didn't take that as a personal complaint about your work, it
(along with lots of maintenance since then) is much appreciated.

> I can say with some confidence that the intention was always the
> requests would block for at most 30 seconds.
...
> > One advantage of waiting for mountd to come back is that you could
> > upgrade mountd in place.  That shouldn't take 30 seconds, though.  And I
> > haven't heard of anyone actually doing that.
> 
> Surely upgrading of mountd in-place happens whenever you install a new
> version.

I didn't think distros restarted mountd on upgrade, but I haven't
actually checked that.  I agree that it's something we should allow,
anyway.

> > It's too bad that not opening auth.unix.gid is the only way for mountd
> > to communicate that gids shouldn't be mapped.
> 
> I have a general preference for reusing existing functionality rather
> than creating new special-purpose functionality.  I think this has
> served me well more often than not.  Maybe this is one case of "not".
> 
> If you want to restart mountd without --managed-gids (where previously
> it had that option), there is a chance that you will hit this problem.
> That is a case where the answer "just stop opening those files" doesn't
> really apply.

Yeah.  OK, applying.

(But I'm traveling and may not get this tested and pushed out till next
week.)

--b.
