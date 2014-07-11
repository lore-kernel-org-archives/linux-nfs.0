Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56601 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755141AbaGKT0e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 15:26:34 -0400
Date: Fri, 11 Jul 2014 15:26:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH] nfsd: close potential race between delegation break and
 laundromat
Message-ID: <20140711192632.GI9775@fieldses.org>
References: <1404759818-10350-1-git-send-email-jlayton@primarydata.com>
 <20140707151450.7abd3db8@tlielax.poochiereds.net>
 <20140707193108.GF8630@fieldses.org>
 <20140707160017.6900c4b4@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140707160017.6900c4b4@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 07, 2014 at 04:00:17PM -0400, Jeff Layton wrote:
> On Mon, 7 Jul 2014 15:31:08 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Jul 07, 2014 at 03:14:50PM -0400, Jeff Layton wrote:
> > > Sigh...after staring at this patch all day, I think I now see a
> > > potential problem with the fault injection piece.
> > > 
> > > In the "recall" case, we may find a delegation on the cl_delegations
> > > list that has already been recalled. If that's the case, then we
> > > probably should just skip it.
> > > 
> > > I'll fix this patch, retest and resend. Sorry for the noise...
> > 
> > OK, so sounds like the fix isn't a big deal, but it also sounds like the
> > fault injection code has come up as needing special attention a few
> > times during this work now.
> > 
> > Has anyone actually ended up using that code?  Anna?
> > 
> > In retrospect I wonder if it's worth the trouble.  It's very
> > special-purpose stuff and if nobody's using it then maybe we could just
> > remove it....
> > 
> > --b.
> 
> I certainly wouldn't object. Having printks that are triggered by
> reading from a debugfs file is just weird, and there are quite a few
> races and bugs in this code.
> 
> I have patches that are basically a rewrite of it, but I left the UI
> the same. It was necessary in order to allow for the changes to the
> locking around this code, but that does mean that it's a larger chunk
> of code than it used to be.
> 
> That said, we've shipped this code in several releases now so removing
> it without any warning might not be a good idea. What may be best is to
> mark it for deprecation if we don't want to keep it, and take my patches
> that overhaul it in the interim. Then, remove it altogether in 2-3
> releases.

Well, if you've already done the work, fine.

If it becomes a problem then I wouldn't rule out removing it summarily.
It's purely for client testing, and if neither Anna nor any of us knows
anyone using it then chances are nobody would notice.

--b.
