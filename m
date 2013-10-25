Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55006 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752995Ab3JYOUN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 10:20:13 -0400
Date: Fri, 25 Oct 2013 10:20:12 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] mountd: disabling turning off TCP listeners (v2)
Message-ID: <20131025142012.GC20497@fieldses.org>
References: <1382638633-6710-1-git-send-email-steved@redhat.com>
 <20131024144507.72aa34a8@tlielax.poochiereds.net>
 <526978BF.7020202@RedHat.com>
 <20131025074316.2affe9e9@tlielax.poochiereds.net>
 <526A62C1.6060803@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <526A62C1.6060803@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 25, 2013 at 08:23:29AM -0400, Steve Dickson wrote:
> 
> 
> On 25/10/13 07:43, Jeff Layton wrote:
> > On Thu, 24 Oct 2013 15:45:03 -0400
> > Steve Dickson <SteveD@redhat.com> wrote:
> > 
> >>
> >>
> >> On 24/10/13 14:45, Jeff Layton wrote:
> >>> On Thu, 24 Oct 2013 14:17:10 -0400
> >>> Steve Dickson <steved@redhat.com> wrote:
> >>>
> >>>> [ Here is the second try for these patches incorporating the code review..]
> >>>>
> >>>> Recently it was pointed out to me that the [-n | --no-tcp] flags 
> >>>> were broken in mountd. Sure enough they are and they broke 
> >>>> when nfs-utils moved to using libtirpc, which was years ago.
> >>>>
> >>>> Obviously nobody is using these flags since has not been 
> >>>> notice until now, but it seemed to me it no longer makes 
> >>>> any sense to have flags. We really want people to use TCP 
> >>>> so why should there be a way to turn it off? It should be
> >>>> the opposite... They should be able to turn off UDP listeners
> >>>> not TCP... 
> >>>>
> >>>>
> >>>> Steve Dickson (3):
> >>>>   mountd: Use protocol bit fields to turn protocols off.
> >>>>   mountd: Deprecate the ability to disable TCP listeners.
> >>>>   mountd: Add the ability to disable UDP listeners.
> >>>>
> >>>>  support/include/rpcmisc.h |  2 +-
> >>>>  support/nfs/rpcmisc.c     | 19 ++++++++++++++-----
> >>>>  support/nfs/svc_create.c  |  5 +++++
> >>>>  utils/mountd/mountd.c     | 17 ++++++++++++-----
> >>>>  utils/mountd/mountd.man   |  6 +++---
> >>>>  5 files changed, 35 insertions(+), 14 deletions(-)
> >>>>
> >>>
> >>> Sorry I'm coming in late on this...
> >> np... I was expecting more push back! ;-) 
> >>
> >>>
> >>> I don't think we want to remove the ability to disable TCP listeners.
> >>>
> >>> Why, you ask? We've been on a multi-year effort to move people to
> >>> NFSv4, and with that, there's no reason to have mountd listen on the
> >>> network at all.
> >> True...
> >>
> >>>
> >>> So personally, I think it would make sense to:
> >>>
> >>> a) allow people to disable listening on UDP in addition to TCP
> >> I see no reason whatsoever to turn off TCP listeners especially
> >> since that is the protocol of choice... something we have 
> >> be spouting about for years...  
> >>  
> > 
> > There are reasons to be able to turn off TCP listeners:
> > 
> > If you're running a NFSv4-only server, there's no reason to allow it to
> > listen on TCP _or_ UDP sockets. I think that sort of environment is
> > going to become more prevalent in the future, not less.
> I ideally it would be best not to have mountd at all on NFSv4-only server.
> Basically, have the kernel get its exports like it gets it ID mappings.
> Until that day comes, which I hope fill be soon, the TCP listener 
> only effects v3 mounts and we definitely want people to use TCP
> with v3. 

I'm not sure if we want to do that, but note one thing we'll need to do
before then is solve the namespace problems.  (We don't currently have a
good way to run the usermode helper in the right container.)

--b.
