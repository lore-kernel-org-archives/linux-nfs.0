Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030510Ab2LGN65 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 08:58:57 -0500
Date: Fri, 7 Dec 2012 08:58:55 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSD: Add support for dynamic slot changes
Message-ID: <20121207135855.GE17115@fieldses.org>
References: <1354159063-17343-1-git-send-email-Trond.Myklebust@netapp.com>
 <1354159063-17343-2-git-send-email-Trond.Myklebust@netapp.com>
 <1354159063-17343-3-git-send-email-Trond.Myklebust@netapp.com>
 <1354159063-17343-4-git-send-email-Trond.Myklebust@netapp.com>
 <1354159063-17343-5-git-send-email-Trond.Myklebust@netapp.com>
 <20121206212908.GB17115@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90B33C86C@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B33C86C@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 06, 2012 at 11:20:15PM +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > Sent: Thursday, December 06, 2012 10:29 PM
> > To: Myklebust, Trond
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: [PATCH 4/4] NFSD: Add support for dynamic slot changes
> > 
> > On Wed, Nov 28, 2012 at 10:17:43PM -0500, Trond Myklebust wrote:
> > > @@ -2159,11 +2223,9 @@ nfsd4_sequence(struct svc_rqst *rqstp,
> > >  	else
> > >  		slot->sl_flags &= ~NFSD4_SLOT_CACHETHIS;
> > >
> > > -	/* Retrieve new target/highest slotid values */
> > > -	spin_lock(&session->se_slots.slt_lock);
> > > -	seq->target_highest_slotid = session-
> > >se_slots.slt_target_highest_slotid;
> > > -	seq->highest_slotid = session->se_slots.slt_highest_slotid;
> > > -	spin_unlock(&session->se_slots.slt_lock);
> > > +	/* Adjust slot table, and retrieve new target/highest slotid values */
> > > +	nfsd4_sequence_adjust_slot_table(session, slot,
> > > +			seq->highest_slotid, seq);
> > 
> > This is allocating under a spin lock (see the client_lock that most of
> > nfsd4_sequence is under.)
> > 
> > (But I'm not sure what we should be doing instead.)
> 
> I've already fixed this issue in the latest patches: the right thing
> is simply to do all this after we drop the client lock.

Oh, sounds reasonable.

> I'll send the
> updated patches when I get a moment: probably Saturday...

Thanks!

--b.
