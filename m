From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 1/2] nfsd4: complete enforcement of 4.1 op ordering
Date: Tue, 27 Apr 2010 12:34:04 -0400
Message-ID: <20100427163404.GH30729@fieldses.org>
References: <1271946744-5877-1-git-send-email-bfields@citi.umich.edu> <20100422144831.GA5926@fieldses.org> <20100423212411.GC1964@fieldses.org> <4BD6F775.2050801@panasas.com> <20100427150103.GC30729@fieldses.org> <4BD706E3.4070608@panasas.com> <20100427161244.GG30729@fieldses.org> <4BD70F5F.7080409@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, postmaster@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48487 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756305Ab0D0QeE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Apr 2010 12:34:04 -0400
In-Reply-To: <4BD70F5F.7080409@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 27, 2010 at 07:22:55PM +0300, Benny Halevy wrote:
> On Apr. 27, 2010, 19:12 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > On Tue, Apr 27, 2010 at 06:46:43PM +0300, Benny Halevy wrote:
> >> On Apr. 27, 2010, 18:01 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> >>> On Tue, Apr 27, 2010 at 05:40:53PM +0300, Benny Halevy wrote:
> >>>> Bruce, Oddly enough I didn't receive the patch you're commenting on into
> >>>> my inbox.  It already happened before on this list and I've no idea what
> >>>> could have went wrong. (I also have a gmail account subscribed on this list
> >>>> and I can't find it there, even in the spam folder :-/)
> >>>
> >>> Huh.  I see it in various archives, so I'll assume the problem's on your
> >>> end.
> >>>
> >>
> >> I see it on the archives too, but since I don't ever erase anything out
> >> of my gmail lists account the fact that it's not there AND not
> >> on my panasas account as well is really suspicious.  I wonder if
> >> vger had some sort of outage or glitch that could explain that.
> > 
> > For what it's worth I've found postmaster at vger.kernel.org can
> > sometimes help troubleshoot problems.
> > 
> > --b.
> 
> Oddly enough, it seems like I'm subscribed this list (called "linux-nfsv4"):
> http://marc.info/?l=linux-nfsv4&r=1&b=201004&w=2
> rather than
> http://marc.info/?l=linux-nfs&r=1&b=201004&w=2
> 
> Although my subscription messages from majordomo@vger.kernel.org
> say "linux-nfs"
> 
> The former is essentially nfsv4@linux-nfs.org, right?
> Maybe I got bounced off of linux-nfs.org for some reason...

The main lists we've been using are:

	linux-nfs@vger.kernel.org
	    nfsv4@linux-nfs.org
	     pnfs@linux-nfs.org

This seems to be confusing.  We've talked before about transitioning
away from one (probably nfsv4@linux-nfs.org).  Maybe now's the time to
start.

(Oh, and there's also an older sourceforge list; I think mail still gets
forwarded from the vger list to there?  Or is it the other way around?
May be time to turn that one off completely.)

--b.
