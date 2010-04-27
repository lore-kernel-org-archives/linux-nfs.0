From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 1/2] nfsd4: complete enforcement of 4.1 op ordering
Date: Tue, 27 Apr 2010 14:10:07 -0400
Message-ID: <20100427181007.GN30729@fieldses.org>
References: <1271946744-5877-1-git-send-email-bfields@citi.umich.edu> <20100422144831.GA5926@fieldses.org> <20100423212411.GC1964@fieldses.org> <4BD6F775.2050801@panasas.com> <20100427150103.GC30729@fieldses.org> <4BD706E3.4070608@panasas.com> <20100427161244.GG30729@fieldses.org> <4BD70F5F.7080409@panasas.com> <20100427163404.GH30729@fieldses.org> <4BD71483.1090604@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36825 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751590Ab0D0SKI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Apr 2010 14:10:08 -0400
In-Reply-To: <4BD71483.1090604@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 27, 2010 at 07:44:51PM +0300, Benny Halevy wrote:
> On Apr. 27, 2010, 19:34 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > The main lists we've been using are:
> > 
> > 	linux-nfs@vger.kernel.org
> > 	    nfsv4@linux-nfs.org
> > 	     pnfs@linux-nfs.org
> > 
> > This seems to be confusing.  We've talked before about transitioning
> > away from one (probably nfsv4@linux-nfs.org).  Maybe now's the time to
> > start.
> 
> I'm all for it.
> Maybe it's time to fold the pnfs list into linux-nfs too.

So, looking back at what we did for the sourceforge list:

	- We added something to the footer saying the list is
	  deprecated.  (But if we wanted to be more obnoxious, we could
	  add it to the top of each message.)

	- We subscribed the new list (linux-nfs@vger.kernel.org) to the
	  old list, I guess so newbie bug reports sent to the old list
	  wouldn't get lost.

Anyone want to object to starting that process for nfsv4@linux-nfs.org?
What about pnfs@linux-nfs.org?

--b.
