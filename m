Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36745 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758140Ab1COQNI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2011 12:13:08 -0400
Date: Tue, 15 Mar 2011 12:13:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: roel <roel.kluin@gmail.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: svc_register error overwritten in next
 iteration
Message-ID: <20110315161301.GA32635@fieldses.org>
References: <4D7B74C7.7060506@gmail.com>
 <20110314223645.GL25442@fieldses.org>
 <13D041DB-A26D-4EC1-A585-7DBA266CF18A@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <13D041DB-A26D-4EC1-A585-7DBA266CF18A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 15, 2011 at 11:43:32AM -0400, Chuck Lever wrote:
> 
> On Mar 14, 2011, at 6:36 PM, J. Bruce Fields wrote:
> 
> > On Sat, Mar 12, 2011 at 02:27:35PM +0100, roel wrote:
> >> The break is in the inner loop, the svc_register() error is overwritten
> >> in the next iteration. Only the error in the last iteration is returned.
> >> 
> >> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> >> ---
> >> net/sunrpc/svc.c |    2 ++
> >> 1 files changed, 2 insertions(+), 0 deletions(-)
> >> 
> >> Is this needed?
> >> 
> >> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> >> index 08e05a8..5fd08c0 100644
> >> --- a/net/sunrpc/svc.c
> >> +++ b/net/sunrpc/svc.c
> >> @@ -889,6 +889,8 @@ int svc_register(const struct svc_serv *serv, const int family,
> >> 			if (error < 0)
> >> 				break;
> > 
> > May as well just "goto out" or "return error" here?
> > 
> > But: aren't we missing some cleanup?  If we succesfully register one
> > program then fail at a second one, don't we need to unregister the
> > first?
> 
> Right.  I don't understand what is the intended effect here (of the original code):  Best effort registration, or "all or none"?

The current code was failing iff the last registration returns an error.
We list the nfs program before the acl program in this list, so nfsd
registration was failing iff the acl program failed, which makes no
sense whatsoever.

I think "all or none" would be cleanest.

If people start complaining that they don't want to run rpcbind/portmap
then we could give them some way of requesting that instead of just
depending on allowing the registration to fail.

For cleanup, we can just unregister everything, right?  (No harm in
possibly unregistering something who's registration just failed?)

--b.
