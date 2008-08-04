From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: high latency NFS
Date: Mon, 4 Aug 2008 15:07:15 -0400
Message-ID: <20080804190715.GJ25940@fieldses.org>
References: <20080730192110.GA17061@fieldses.org> <4890DFC7.3020309@cse.unsw.edu.au> <200807302235.50068.shuey@purdue.edu> <20080731031512.GA26203@fieldses.org> <18577.25513.494821.481623@notabene.brown> <20080801072320.GE6201@disturbed> <20080801191559.GI7764@fieldses.org> <20080804003206.GB6119@disturbed> <52873.192.168.1.70.1217813385.squirrel@neil.brown.name> <4896A4EE.9030706@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@suse.de>, Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>,
	Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, aglo@citi.umich.edu
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52597 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761248AbYHDTHW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2008 15:07:22 -0400
In-Reply-To: <4896A4EE.9030706-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 04, 2008 at 04:42:54PM +1000, Greg Banks wrote:
> NeilBrown wrote:
> > On Mon, August 4, 2008 10:32 am, Dave Chinner wrote:
> >   
> >>>> i.e. take the solution that Greg banks used for the CPU scheduler
> >>>> overload issue (limiting the number of nfsds woken but not yet on
> >>>> the CPU),
> >>>>         
> >
> > Ahh... I remembered Greg talking about that, went looking, and
> > couldn't find it.  I couldn't even find any mail about it, yet I'm
> > sure I saw a patch..
> >   
> http://marc.info/?l=linux-nfs&m=115501004819230&w=2
> > Greg: Do you remember what happened to this?  Did I reject it for some
> > reason, or did it never get sent?  or ...
> >   
> I think we got all caught up arguing about the other patches in the
> batch (the last round of the everlasting  "dynamic nfsd management for
> Linux" argument) and between us we managed to drop the patch on the ground.
> 
> http://thread.gmane.org/gmane.linux.nfs/10372
> 
> I think the only part of that patchset that you explicitly rejected was
> the one where I tried to kill off the useless "th" line in
> /proc/net/rc/nfsd.

Looks like that was me, apologies.  Breaking a documented interface to
userspace just set off an alarm.  But if we really convince ourselves
that it's useless, then OK.

(Though maybe your idea of leaving the line in place with just constant
zeros is good.  Just because the data's useless doesn't mean someone out
there may have a script that does otherwise useful things but that
happens to fail if it can't parse /proc/net/rpc/nfsd.)

Looks like it's been two years now--any chance of rebasing those patches
and resending?

--b.
