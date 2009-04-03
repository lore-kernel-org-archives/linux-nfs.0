From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 40/47] nfsd41: cb_sequence callback
Date: Thu, 2 Apr 2009 22:34:20 -0400
Message-ID: <20090403023420.GC30324@fieldses.org>
References: <20090402205408.GA18195@fieldses.org> <273FE88A07F5D445824060902F70034405026F00@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60738 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554AbZDCCeW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 22:34:22 -0400
In-Reply-To: <273FE88A07F5D445824060902F70034405026F00-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 02, 2009 at 06:06:55PM -0700, Labiaga, Ricardo wrote:
> Yes, the NFS client uses a slot table for the forechannel 'struct
> nfs4_slot_table' and a slot table for the backchannel.  Tasks sleep on
> an rpc_wait_queue if there are no available slots.  Used/ unused slots
> are tracked with a bit map array.  When the reply is received on a slot,
> the next available task is awaken.
> 
> Yes, the callback client can certainly do the same thing.  Today, the
> Linux client backchannel only advertises a single slot (need to check
> what Solaris does).  So against Linux, having more than one slot doesn't
> buy the server much right now.
> 
> Is this something that can be addressed as an enhancement later on, or
> do you need this implemented right away?

I'm dropping the backchannel patches for 2.6.30, so it isn't urgent, but
this is something to work on over the next month or two.

I'd just like an asynchronous solution, so no big mutexes.  I'm fine
with the single-slot limitation if it helps, but maybe the simplest
thing will be just to imitate the nfs-client code?

--b.
