Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36528 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751280AbdDCCjG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Apr 2017 22:39:06 -0400
Date: Sun, 2 Apr 2017 22:39:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Jason Yan <yanaijie@huawei.com>, jlayton@poochiereds.net,
        linux-nfs@vger.kernel.org, miaoxie@huawei.com,
        zhaohongjiang@huawei.com, Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] nfsd: make strdup_if_nonnull static
Message-ID: <20170403023905.GA19658@fieldses.org>
References: <1490259456-15858-1-git-send-email-yanaijie@huawei.com>
 <20170329215132.GC29934@fieldses.org>
 <874lyb5kc8.fsf@notabene.neil.brown.name>
 <20170331200909.GC8487@fieldses.org>
 <87lgridyn8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87lgridyn8.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 03, 2017 at 12:15:55PM +1000, NeilBrown wrote:
> On Fri, Mar 31 2017, J. Bruce Fields wrote:
> 
> > On Thu, Mar 30, 2017 at 05:50:47PM +1100, NeilBrown wrote:
> >> On Wed, Mar 29 2017, J. Bruce Fields wrote:
> >> 
> >> > Thanks, applying for 4.12.--b.
> >> 
> >> Ugh... does strdup_if_nonnull() actually help readability at all?
> >> kstrdup() already handles NULL fine, which is what the name seems to
> >> suggest is happening.
> >> I would think kstrdup_report_error() is a name that better reflects the
> >> function.
> >> 
> >> Or just discard it:
> >
> > Yes, what was I thinking?  Just didn't read kstrdup(), I guess.
> > Applying as follows.
> 
> 
> Thanks.
> Feel free to add
>   Signed-off-by: NeilBrown <neilb@suse.com>
> 
> I probably should have stuck that in there in the first place, just in
> case.

For a small patch from a known contributor I figure the risk of just
assuming DCO case (c) is negligible.  Anyway, added, thanks.

--b.
