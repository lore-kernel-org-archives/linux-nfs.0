From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [PATCH v2 40/47] nfsd41: cb_sequence callback
Date: Fri, 3 Apr 2009 14:15:46 -0700
Message-ID: <273FE88A07F5D445824060902F700344050273F5@SACMVEXC1-PRD.hq.netapp.com>
References: <20090403023420.GC30324@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Benny Halevy" <bhalevy@panasas.com>, <linux-nfs@vger.kernel.org>,
	<pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61550 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753017AbZDCVRG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 17:17:06 -0400
In-Reply-To: <20090403023420.GC30324@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Thursday, April 02, 2009 7:34 PM
> To: Labiaga, Ricardo
> Cc: Benny Halevy; linux-nfs@vger.kernel.org; pnfs@linux-nfs.org
> Subject: Re: [PATCH v2 40/47] nfsd41: cb_sequence callback
> 
> On Thu, Apr 02, 2009 at 06:06:55PM -0700, Labiaga, Ricardo wrote:
> > Yes, the NFS client uses a slot table for the forechannel 'struct
> > nfs4_slot_table' and a slot table for the backchannel.  Tasks sleep
on
> > an rpc_wait_queue if there are no available slots.  Used/ unused
slots
> > are tracked with a bit map array.  When the reply is received on a
slot,
> > the next available task is awaken.
> >
> > Yes, the callback client can certainly do the same thing.  Today,
the
> > Linux client backchannel only advertises a single slot (need to
check
> > what Solaris does).  So against Linux, having more than one slot
doesn't
> > buy the server much right now.
> >
> > Is this something that can be addressed as an enhancement later on,
or
> > do you need this implemented right away?
> 
> I'm dropping the backchannel patches for 2.6.30, so it isn't urgent,
but
> this is something to work on over the next month or two.
> 
> I'd just like an asynchronous solution, so no big mutexes.  I'm fine
> with the single-slot limitation if it helps, but maybe the simplest
> thing will be just to imitate the nfs-client code?
> 

Sounds good, I can work on this.

- ricardo
