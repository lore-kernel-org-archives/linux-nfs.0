Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58254 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753966Ab1KAORr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Nov 2011 10:17:47 -0400
Date: Tue, 1 Nov 2011 10:17:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSD: Added fault injection
Message-ID: <20111101141746.GD32248@fieldses.org>
References: <1319455259-3136-1-git-send-email-bjschuma@netapp.com>
 <20111028212450.GA7441@fieldses.org>
 <4EAFFD65.4010407@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EAFFD65.4010407@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 01, 2011 at 10:08:37AM -0400, Bryan Schumaker wrote:
> On Fri 28 Oct 2011 05:24:50 PM EDT, J. Bruce Fields wrote:
> > On Mon, Oct 24, 2011 at 07:20:57AM -0400, bjschuma@netapp.com wrote:
> > ...
> >> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> >> index db34a58..e67f30c 100644
> >> --- a/fs/nfsd/nfsctl.c
> >> +++ b/fs/nfsd/nfsctl.c
> > ...
> >> @@ -1130,6 +1131,9 @@ static int __init init_nfsd(void)
> >>  	retval = nfs4_state_init(); /* nfs4 locking state */
> >>  	if (retval)
> >>  		return retval;
> >> +	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
> >> +	if (retval)
> >> +		goto out_cleanup_fault_injection;
> >>  	nfsd_stat_init();	/* Statistics */
> >>  	retval = nfsd_reply_cache_init();
> >>  	if (retval)
> >> @@ -1161,6 +1165,8 @@ out_free_cache:
> >>  out_free_stat:
> >>  	nfsd_stat_shutdown();
> >>  	nfsd4_free_slabs();
> >> +out_cleanup_fault_injection:
> >> +	nfsd_fault_inject_cleanup();
> >
> > Check the cleanup here again....  The slabs are allocated in state_init,
> > so you need to do that on nfsd_fault_inject_init, but you *don't* need
> > the fault_inject_cleanup in that case, since fault_inject_init cleanup
> > cleans up after itself--that's needed only on later failures.
> 
> Would it be better to change the fault_inject_init() function so it 
> doesn't clean up after itself?  This would keep it consistent with the 
> other nfsd init functions.

I don't think so.  The pattern here is pretty common throughout the
kernel; it's approximately:

	do_thing1();
	err = do_thing2();
	if (err)
		goto undo_thing1;
	err = do_thing3();
	if (err)
		goto undo_thing2;
	...

Functions are no-ops on failure, and the caller's just responsible for
cleaning up previous stuff.

> I didn't realize that slabs were initialized in the state_init()
> function, I'll fix that.

I'll admit that's confusing.  Any suggestion to make it clearer welcome.

--b.
