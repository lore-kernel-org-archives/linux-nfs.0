From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: about NLM/NSM
Date: Tue, 28 Oct 2008 10:31:36 -0700
Message-ID: <1225215096.28654.18.camel@dyn9047022153>
References: <55BA1E9645B3441FA782D9032BDC9288@nrchpcvx1f5w93>
	 <20081027185515.GB23767@fieldses.org> <49061511.4050304@redhat.com>
	 <20081027201323.GA25467@fieldses.org> <49062F3E.6090206@redhat.com>
	 <20081027211740.GC25467@fieldses.org>  <490630AE.4000807@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	hexf <hexiaofeng-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>, linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:43932 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752434AbYJ1R2D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2008 13:28:03 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9SHS0th030618
	for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2008 13:28:00 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9SHRxGu096130
	for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2008 13:27:59 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9SHRwao013917
	for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2008 13:27:59 -0400
In-Reply-To: <490630AE.4000807@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-10-27 at 17:20 -0400, Peter Staubach wrote:
> J. Bruce Fields wrote:
> > On Mon, Oct 27, 2008 at 05:14:38PM -0400, Peter Staubach wrote:
> >   
> >> J. Bruce Fields wrote:
> >>     
> >>> On Mon, Oct 27, 2008 at 03:22:57PM -0400, Peter Staubach wrote:
> >>>   
> >>>       
> >>>> J. Bruce Fields wrote:
> >>>>     
> >>>>         
> >>>>> On Mon, Oct 27, 2008 at 02:49:27PM +0800, hexf wrote:
> >>>>>         
> >>>>>           
> >>>>>> We are using nfsv3. Now we meet a demand. If a client which hold a
> >>>>>> lock crash, after it reboot, its statd daemon can notify the nfs
> >>>>>> server to release the lock.  But if this client will not reboot for
> >>>>>> some reason(or will reboot after a long time), then the lock it
> >>>>>> holding will not be released.In nfsv3 and nlmv4,it seems there is no
> >>>>>> time-out mechnism for this situation. How would we solve this
> >>>>>> question? My colleague advise me to modify the code of NLM/NSM to meet
> >>>>>> this demand,but is seems quite a complicated work.Can you give me some
> >>>>>> advice?
> >>>>>>             
> >>>>>>             
> >>>>> It might be possible to modify the server so that it dropped all locks
> >>>>> from a client it hadn't heard from in a while.  However, nfsv2/v3
> >>>>> clients are not required to contact the server regularly while they hold
> >>>>> locks.  So you may end up revoking locks held by perfectly good
> >>>>> functioning clients.
> >>>>>
> >>>>> As an ugly workaround, rebooting the server will clear the problem, as
> >>>>> it will notify clients to recover their locks on restart, and any dead
> >>>>> clients will fail to recover their locks.
> >>>>>
> >>>>>         
> >>>>>           
> >>>> Didn't Wendy Cheng submit some patches to implement a
> >>>> "clearlocks" sort of functionality?  What happened with
> >>>> them?
> >>>>     
> >>>>         
> >>> Yes, but that's motivated by the case of migrating all clients using one
> >>> export; so it'll drop all locks held on a single filesystem, or all
> >>> locks acquired using a single server (not client!) ip address.
> >>>
> >>> So if we want some finer-grained interface then that's yet to be
> >>> designed.
> >>>   
> >>>       
> >> Sorry, I guess that I was remembering incorrectly.  I was
> >> thinking that she was looking for something like the clearlocks
> >> functionality so that file systems could be migrated around
> >> cleanly.
> >>     
> >
> > That's what she was working on (and we merged), yes.
> >
> > But it doesn't help clear just the set of locks held by a single client.
> >
> >   
> >> It seems for this situation, we could use this sort of variation.
> >>     
> >
> > I'm losing track of what those two "this"'s refer to!
> >   
> 
> Sorry -- :-)
> 
> For the situation of needing to clear locks belonging to long
> dead and not returning clients, we could use a variation of
> Wendy's proposal which works using the client IP as the key.

Wouldn't this be pretty easy to do with a user space tool that just
calls lockd's SM_NOTIFY procedure? Sure, it's a private interface (as
far as what proc # - but it's pretty well known that lockd always
provides SM_NOTIFY on the same proc #), but there's no real need to add
a new kernel interface unless we want to generalize the clearlocks
interface.

The tool just needs to use loopback and a privileged port.

Frank


