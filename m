From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 1/2] nfsd4: complete enforcement of 4.1 op ordering
Date: Tue, 27 Apr 2010 11:01:03 -0400
Message-ID: <20100427150103.GC30729@fieldses.org>
References: <1271946744-5877-1-git-send-email-bfields@citi.umich.edu> <20100422144831.GA5926@fieldses.org> <20100423212411.GC1964@fieldses.org> <4BD6F775.2050801@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41447 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756163Ab0D0PBE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Apr 2010 11:01:04 -0400
In-Reply-To: <4BD6F775.2050801@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 27, 2010 at 05:40:53PM +0300, Benny Halevy wrote:
> Bruce, Oddly enough I didn't receive the patch you're commenting on into
> my inbox.  It already happened before on this list and I've no idea what
> could have went wrong. (I also have a gmail account subscribed on this list
> and I can't find it there, even in the spam folder :-/)

Huh.  I see it in various archives, so I'll assume the problem's on your
end.

> comments below...
> 
> On Apr. 24, 2010, 0:24 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > Benny--I coded up a simple (possibly incorrect) implementation of this,
> > and then remembered that this was more or less what your
> > state-lock-reduction-prep patch series did.  Do you have a more recent
> > version of those patches?
> 
> Yup.  though untested with latest bits.
> I'll resend it as a reply to this message.

I think what we actually want is a mechanism with semantics like yours,
but with multiple RENEW values so we can track how many users there are
and have only the last one do the renew.

One possibility: 

	- add a cl_users field, with:
		cl_user>0 meaning: somebody's using this client right
			now, don't expire it.  (Your RENEW state.)
		cl_user<0 meaning: this client is already being expired,
			don't try to use it (or any sessionid or other
			state associated with it). (Your EXPIRED state.)
		cl_user==0: fair game to either use or (if expiry time
			has passed) to expire. (Your NORMAL state.)

	- add a cl_renewme boolean, meaning: last user of this client
	  (user to decrement to 0) should renew the client (reset the
	  expiry time and move it to the back of the lru).

So:

	- in laundromat: 
		- atomically check whether cl_users is 0, and, if so,
		  decrement to -1.  (If positive, skip expiring this
		  client.)

	- on looking up a sessionid (or, eventually, any state object
	  associated with a client), call get_client(), which:
		- atomically checks whether cl_users is >=0, and, if so,
		  increments it.  If <0, fail to find the object and
		  return an appropriate error (STALE?).
	- on renew:
		- BUG_ON(cl_user<=0)
		- set cl_renewme
	- on dropping reference to a sessionid (or, eventually, any
	  state object associated with a client), call put_client(),
	  which:
		- atomically decrements cl_users, checks whether it hits
		  zero, and (if so, and if cl_renewme set), renews the
		  client.

One possible implementation: make cl_users atomic, add a per-client
spinlock, make the put_client() do an atomic_dec_and_lock(), etc.

--b.
