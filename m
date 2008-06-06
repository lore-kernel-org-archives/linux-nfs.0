From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/4] knfsd: Replace lock_kernel with a mutex for nfsd
 thread startup/shutdown locking.
Date: Fri, 6 Jun 2008 11:05:02 -0400
Message-ID: <20080606110502.7e4f3967@tleilax.poochiereds.net>
References: <1212591796-22144-1-git-send-email-jlayton@redhat.com>
	<1212591796-22144-2-git-send-email-jlayton@redhat.com>
	<484737A9.508@melbourne.sgi.com>
	<20080605200358.GB5829@fieldses.org>
	<48487857.4030706@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756950AbYFFPFU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Jun 2008 11:05:20 -0400
In-Reply-To: <48487857.4030706-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 06 Jun 2008 09:35:51 +1000
Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> wrote:

> J. Bruce Fields wrote:
> > On Thu, Jun 05, 2008 at 10:47:37AM +1000, Greg Banks wrote:
> >   
> >> I notice there's no change to write_leasetime().  That calls
> >> nfs4_reset_lease(), which seems to want to only be called when nfsd is
> >> not started (according to my reading of the comment preceding the
> >> function), and which uses the BKL to protect the variable
> >> user_lease_time.  Perhaps that path should be changed to use the new
> >> nfsd_mutex also?
> >>     
> >
> > write_leasetime() just results in setting the user_lease_time, which is
> > copied (once, on server startup) to lease_time, which is what is
> > actually used by the running server.
> Yes, understood.
> >   So I don't think there's a race
> > here (and the existing BKL use in write_leasetime() isn't really
> > needed).
> >   
> The race is pretty harmless.  The only read of user_lease_time happens
> during the critical section currently guarded by the BKL in nfsd_svc();
> the only write of the variable is not guarded by that lock.  If you call
> write_leasetime() many times with different values during nfsd startup,
> the actual value used is not predictable and you can't tell from
> userspace whether your write() succeeded in changing the behaviour of
> the server or not.  Also, you can do write_leasetime() after nfsd
> startup without useful effect; other parameters which can't be changed
> from /proc after the service is running will fail the write() with EBUSY.
> 

The race there is pretty harmless, but fixing it sounds like it'll be low
impact. I don't expect that the nfsd_mutex will be highly contended,
so adding some locking around these interfaces really shouldn't harm
anything.

Also, as you point out, many of these interfaces should return -EBUSY if
nfsd is up (to be consistent with how write_versions behaves), and we'll
need proper locking to do that.

I've got a new patchset that should hopefully address these problems and
some of your other comments that I'll post in a little while...

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
