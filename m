Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38534 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933278Ab1IIMG2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 08:06:28 -0400
Date: Fri, 9 Sep 2011 08:06:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] NFSD patches to support junctions
Message-ID: <20110909120628.GJ17215@fieldses.org>
References: <20110902162210.32190.5880.stgit@matisse.1015granger.net>
 <20110908175946.GA16740@fieldses.org>
 <20110908182415.GD16740@fieldses.org>
 <333285BF-5D19-41C2-AAFB-60BE49F64C1F@oracle.com>
 <20110908192143.GA17215@fieldses.org>
 <4724D1E3-1A56-4D0A-8A3F-64A5F0C1F5FC@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4724D1E3-1A56-4D0A-8A3F-64A5F0C1F5FC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 08, 2011 at 09:47:50PM -0700, Chuck Lever wrote:
> 
> On Sep 8, 2011, at 12:21 PM, J. Bruce Fields wrote:
> 
> > On Thu, Sep 08, 2011 at 12:03:49PM -0700, Chuck Lever wrote:
> >> 
> >> On Sep 8, 2011, at 11:24 AM, J. Bruce Fields wrote:
> >> 
> >>> On Thu, Sep 08, 2011 at 01:59:46PM -0400, bfields wrote:
> >>>> On Fri, Sep 02, 2011 at 12:38:13PM -0400, Chuck Lever wrote:
> >>>>> Sometime soon we are going to have easy-to-install user space FedFS
> >>>>> components.  Here are kernel patches needed to make server-side FedFS
> >>>>> support work.  Please consider these for the 3.2 kernel.
> >>>>> 
> >>>>> The third patch introduces a potentially expensive check to see if
> >>>>> a junction has been encountered during a mountpoint lookup.  An object
> >>>>> is a junction iff it has the requisite set of extended attributes.
> >>>>> However, reading an extended attribute is expensive on some file
> >>>>> systems.
> >>>>> 
> >>>>> To mitigate the cost of this check, junctions always have their sticky
> >>>>> bit set.  The expensive extended attribute part of the junction test
> >>>>> is done only if the sticky bit is present.
> >>>>> 
> >>>>> Note that today junctions are directories, but someday symlinks might
> >>>>> also act as junctions (for SMB2 support).  And very few files have the
> >>>>> sticky bit set.  So we avoid doing a directory test here.
> >>>>> 
> >>>>> Also, junctions ostensibly have all zero mode bits to hide their local
> >>>>> contents.  I don't think the kernel needs to be concerned about the
> >>>>> permissions as long as the sticky bit is set.  This allows some
> >>>>> flexibility in how junctions are represented.  However, Jeff thinks
> >>>>> that having nfsd4_is_junction() also consider mode bits would make the
> >>>>> expensive part of this test still less frequent.
> >>>>> 
> >>>>> Any thoughts about this?
> >>>> 
> >>>> Hm, right, a sticky bit set on a directory is a normal thing.  I thought
> >>>> Trond's original idea was to check for the sticky bit and not
> >>>> executable?  Which is a pointless combination so should be very rare.
> >>>> 
> >>>> On a typical system maybe directories with the sticky bit are normally
> >>>> somewhat rare, but that's a question of policy and there could be cases
> >>>> where it's common.
> >>> 
> >>> Except for that and the one gripe about an error return, it looks fine
> >>> to me.
> >> 
> >> Noted.  I can repost these with requested fixes in a day or two.
> >> 
> >>> Remind me where the corresponding userland code is?
> >> 
> >> http://oss.oracle.com/projects/fedfs-utils
> > 
> > I can find gitweb, but not a git url to clone from.
> 
> Try
> 
>   git clone git://oss.oracle.com/git/cel/fedfs-utils.git

Got it, thanks!

(There should be some way to configure your gitweb installation so it
includes that.)

--b.
