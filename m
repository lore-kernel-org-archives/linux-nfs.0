Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45086 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813Ab2CHSxw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 13:53:52 -0500
Date: Thu, 8 Mar 2012 13:53:50 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] exportfs: Stop racing exportfs on clusters
Message-ID: <20120308185350.GA9273@fieldses.org>
References: <1331150190-18401-1-git-send-email-steved@redhat.com>
 <20120307203649.GA582@fieldses.org>
 <20120307205005.GB582@fieldses.org>
 <AAB0D4F3-A275-482E-A520-06715885B08F@oracle.com>
 <4F58CC1E.4030805@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F58CC1E.4030805@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 08, 2012 at 10:11:26AM -0500, Steve Dickson wrote:
> 
> 
> On 03/07/2012 03:52 PM, Chuck Lever wrote:
> > 
> > On Mar 7, 2012, at 3:50 PM, J. Bruce Fields wrote:
> > 
> >> On Wed, Mar 07, 2012 at 03:36:49PM -0500, bfields wrote:
> >>> On Wed, Mar 07, 2012 at 02:56:30PM -0500, Steve Dickson wrote:
> >>>> This problem can occur when multiple cluster services fail over
> >>>> at the same time, causing missing high-available exports.
> >>>> Having a lot of nfs-exports will trigger this issue easier.
> >>>
> >>> Isn't the locking in support/export/xtab.c supposed to take care of
> >>> this?
> >>
> >> Huh, maybe that's just meant to prevent etab from getting corrupted, or
> >> mountd from seeing a partially-written file.
> >>
> >> But it probably doesn't prevent two exportfs processes from both reading
> >> etab, adding an export, and each writing out an etab with its one export
> >> added, with the last writer winning.
> >>
> >> Was that the problem?
> > 
> > For bug 224, yes.  After disparate concurrent exportfs commands race, the etab file ends up missing some exports.
> This morning I took another look at this and there does indeed need to
> be some global lock to stop to serialize dueling exportfs commands. The
> locks in xtab.c are just to granular....

Right, makes sense.  So just in hopes that I don't ask the same question
next time this comes up, could we find a good spot for a comment, maybe
something like this?:

	/*
	 * If we aren't careful, changes made by exportfs can be lost
	 * when multiple exports process run at once:
	 *
	 *	exportfs process 1	exportfs process 2
	 *	------------------------------------------
	 *	reads etab version A	reads etab version A
	 *	adds new export B	adds new export C
	 *	writes A+B		writes A+C
	 
	 * The locking in support/export/xtab.c will prevent mountd from
	 * seeing a partially written version of etab, and will prevent 
	 * the two writers above from writing simultaneously and
	 * corrupting etab, but to prevent problems like the above we
	 * need this additional lock:
	 */

Uh, or maybe you can come up with something shorter.

--b.
