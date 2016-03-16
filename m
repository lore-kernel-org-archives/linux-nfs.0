Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33454 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934826AbcCPPFN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 11:05:13 -0400
Date: Wed, 16 Mar 2016 11:05:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: William Dauchy <wdauchy@gmail.com>
Cc: NeilBrown <neilb@suse.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc/cache: drop reference when
 sunrpc_cache_pipe_upcall() detects a race
Message-ID: <20160316150510.GE11520@fieldses.org>
References: <87y49ylq76.fsf@notabene.neil.brown.name>
 <20160314203846.GA22276@fieldses.org>
 <CAJ75kXbNjwaf-QWQPq1=ooUxAPmA5qBEH9jGv+k92NEr-4eJXQ@mail.gmail.com>
 <20160315131959.GA419@fieldses.org>
 <87vb4nh406.fsf@notabene.neil.brown.name>
 <CAJ75kXaWqMSgjp4U=M5Jz7VUXt_yJTo31MTQV0fh1R1TV9_W7Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJ75kXaWqMSgjp4U=M5Jz7VUXt_yJTo31MTQV0fh1R1TV9_W7Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 16, 2016 at 08:31:03AM +0100, William Dauchy wrote:
> Hi Bruce,
> 
> Thank you for your reply.
> 
> On Tue, Mar 15, 2016 at 9:37 PM, NeilBrown <neilb@suse.com> wrote:
> > I agree that it isn't needed for stable - the race is tiny and the
> > consequence of losing the race is that entries get stuck in the cache
> > and possible an exported filesystem cannot be unmounted.
> 
> I believe in an industrial usage, this race will become more common;

Why is that?

> moreover the consequence of an exported filesystem which can't be
> unmounted is not something I can accept in some environment.
> 
> I accept your judgment about including it or not in -stable but I am
> just complaining about the lack of further consideration for those
> type of fixes in nfs generally speaking. In an industrial usage, we
> are hitting races way more easily than in a normal usage; lost of them
> are already fixed and we do backports ourself.

Do you have a list?

> We are at a point where
> it becomes almost impossible to come with a proof and say "we are
> hitting this race, and this patch fixes the issue, please backport in
> -stable".

I don't expect *proof*, necessarily, but some sort of argument would be
helpful.

--b.
