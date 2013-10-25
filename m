Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11899 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753361Ab3JYNDM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 09:03:12 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9PD3CnV017655
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 25 Oct 2013 09:03:12 -0400
Date: Fri, 25 Oct 2013 09:03:10 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] mountd: disabling turning off TCP listeners (v2)
Message-ID: <20131025090310.4a38895c@tlielax.poochiereds.net>
In-Reply-To: <526A6A3B.2090107@RedHat.com>
References: <1382638633-6710-1-git-send-email-steved@redhat.com>
	<20131024144507.72aa34a8@tlielax.poochiereds.net>
	<526978BF.7020202@RedHat.com>
	<20131025074316.2affe9e9@tlielax.poochiereds.net>
	<526A62C1.6060803@RedHat.com>
	<20131025082901.45d5bc3e@tlielax.poochiereds.net>
	<526A6A3B.2090107@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 25 Oct 2013 08:55:23 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 25/10/13 08:29, Jeff Layton wrote:
> > On Fri, 25 Oct 2013 08:23:29 -0400
> > Steve Dickson <SteveD@redhat.com> wrote:
> > 
> >>
> >>
> >> On 25/10/13 07:43, Jeff Layton wrote:
> >>> On Thu, 24 Oct 2013 15:45:03 -0400
> >>> Steve Dickson <SteveD@redhat.com> wrote:
> >>>
> >>>>
> >>>>
> >>>> On 24/10/13 14:45, Jeff Layton wrote:
> >>>>> On Thu, 24 Oct 2013 14:17:10 -0400
> >>>>> Steve Dickson <steved@redhat.com> wrote:
> >>>>>
> >>>>>> [ Here is the second try for these patches incorporating the code review..]
> >>>>>>
> >>>>>> Recently it was pointed out to me that the [-n | --no-tcp] flags 
> >>>>>> were broken in mountd. Sure enough they are and they broke 
> >>>>>> when nfs-utils moved to using libtirpc, which was years ago.
> >>>>>>
> >>>>>> Obviously nobody is using these flags since has not been 
> >>>>>> notice until now, but it seemed to me it no longer makes 
> >>>>>> any sense to have flags. We really want people to use TCP 
> >>>>>> so why should there be a way to turn it off? It should be
> >>>>>> the opposite... They should be able to turn off UDP listeners
> >>>>>> not TCP... 
> >>>>>>
> >>>>>>
> >>>>>> Steve Dickson (3):
> >>>>>>   mountd: Use protocol bit fields to turn protocols off.
> >>>>>>   mountd: Deprecate the ability to disable TCP listeners.
> >>>>>>   mountd: Add the ability to disable UDP listeners.
> >>>>>>
> >>>>>>  support/include/rpcmisc.h |  2 +-
> >>>>>>  support/nfs/rpcmisc.c     | 19 ++++++++++++++-----
> >>>>>>  support/nfs/svc_create.c  |  5 +++++
> >>>>>>  utils/mountd/mountd.c     | 17 ++++++++++++-----
> >>>>>>  utils/mountd/mountd.man   |  6 +++---
> >>>>>>  5 files changed, 35 insertions(+), 14 deletions(-)
> >>>>>>
> >>>>>
> >>>>> Sorry I'm coming in late on this...
> >>>> np... I was expecting more push back! ;-) 
> >>>>
> >>>>>
> >>>>> I don't think we want to remove the ability to disable TCP listeners.
> >>>>>
> >>>>> Why, you ask? We've been on a multi-year effort to move people to
> >>>>> NFSv4, and with that, there's no reason to have mountd listen on the
> >>>>> network at all.
> >>>> True...
> >>>>
> >>>>>
> >>>>> So personally, I think it would make sense to:
> >>>>>
> >>>>> a) allow people to disable listening on UDP in addition to TCP
> >>>> I see no reason whatsoever to turn off TCP listeners especially
> >>>> since that is the protocol of choice... something we have 
> >>>> be spouting about for years...  
> >>>>  
> >>>
> >>> There are reasons to be able to turn off TCP listeners:
> >>>
> >>> If you're running a NFSv4-only server, there's no reason to allow it to
> >>> listen on TCP _or_ UDP sockets. I think that sort of environment is
> >>> going to become more prevalent in the future, not less.
> >> I ideally it would be best not to have mountd at all on NFSv4-only server.
> >> Basically, have the kernel get its exports like it gets it ID mappings.
> >> Until that day comes, which I hope fill be soon, the TCP listener 
> >> only effects v3 mounts and we definitely want people to use TCP
> >> with v3. 
> >>  
> > 
> > We want people to use TCP for NFS protocol with v3. In general however,
> > we do *not* want them using TCP for the MNT protocol. We've had many
> > problems in the past with clients hitting reserved port exhaustion due
> > to using TCP for short-lived sockets to carry MNT traffic. This is the
> > reason that the client defaults to UDP for MNT traffic.
> True... but with v4 now being the default, the admin would really have
> to change things for this to happen... 
> 
> I guess I really don't care if they can or can not turn off UDP,
> I just think it makes sense  for people to be able to disable
> the best transport for v3 mounts... 
> 
> steved.
> 

Ok, but then we go back to my original point. The best configuration
in a v4-only environment is to prevent mountd from listening on any
sockets. If you add the '-u' flag, and fix the '-n' flag, then users
can do that. OTOH, adding a -u flag and getting rid of the -n flag
seems pointless.

Let's step back a moment...

Why do you think it's better for v2/3 clients to use TCP vs. UDP for
MNT traffic? I've always thought that the reverse is true since these
sockets are almost always very short-lived.

-- 
Jeff Layton <jlayton@redhat.com>
