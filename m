From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] NFSD EOS deferral
Date: Mon, 20 Oct 2008 14:06:37 -0400
Message-ID: <20081020180637.GB23927@fieldses.org>
References: <1224104426-12293-1-git-send-email-andros@netapp.com> <20081017174454.GB11884@fieldses.org> <OF9E4C4BA6.37418EC7-ON882574E5.0067FB2B-882574E5.0068487F@us.ibm.com> <RTPCLUEXC1-PRDidcDj000001ca@RTPMVEXC1-PRD.hq.netapp.com> <20081017203629.GB14960@fieldses.org> <RTPCLUEXC1-PRDarcR4000001cd@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Eshel <eshel@almaden.ibm.com>, andros@netapp.com,
	linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59176 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754432AbYJTSGo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 14:06:44 -0400
In-Reply-To: <RTPCLUEXC1-PRDarcR4000001cd-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 17, 2008 at 04:51:00PM -0400, Talpey, Thomas wrote:
> At 04:36 PM 10/17/2008, J. Bruce Fields wrote:
> >On Fri, Oct 17, 2008 at 04:26:18PM -0400, Talpey, Thomas wrote:
> >> At 02:59 PM 10/17/2008, Marc Eshel wrote:
> >> >linux-nfs-owner@vger.kernel.org wrote on 10/17/2008 10:44:54 AM:
> >> >
> >> >> "J. Bruce Fields" <bfields@fieldses.org> 
> >> >> Requests longer than a page are still not deferred, so large writes that
> >> >> trigger upcalls still get an ERR_DELAY.  OK, probably no big deal.
> >> >> 
> >> >> I don't think we can apply this until we have some way to track the
> >> >> number and size of deferred requests outstanding and fall back on
> >> >> ERR_DELAY if it's too much.
> >> >
> >> >But I thought that the problem here is that the Linux NFS client doesn't 
> >> >handle this return code properly.
> >> 
> >> Definitely this is an issue. Early clients do one of two things, they either
> >> pass the error back to the application, or they enter a buzz loop resending
> >> the operation with no delay. Later clients back off, but for a constant
> >> five seconds.
> >
> >I haven't tested it, but from fs/nfs/nfs4proc.c:nfs4_delay() it appears
> >to start at a tenth of a second and then do exponential backoff (up to
> >15 seconds).  Looks to me like the code's been that way since at least
> >2.6.19.
> 
> I was referring to NFSv3, actually - also impacted by this codepath.

OK, sorry.

Hm, taking another look: nfs3_rpc_wrapper() uses a constant 5 second
delay, and nfs4_async_handle_error() uses a constant 15 second delay, so
it's only nfs4_handle_exception that does the exponential backoff.
Maybe we could fix that.

--b.

> But I'll take the opportunity to point out that we'll get 5 retries from
> an NFSv4 client before 2 seconds go by, and only one from NFSv3
> in twice that. In either case, it's a heck of a bad trade to return "I'm
> busy" only to have your bell rung repeatedly in response.
> 
> Sorry, I have always hated EJUKEBOX.
