Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57031 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754807Ab1G0UhD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:37:03 -0400
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>,
        Bryan Schumaker <bjschuma@netapp.com>
Cc: Justin Piszcz <jpiszcz@lucidpixels.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Date: Wed, 27 Jul 2011 16:37:01 -0400
In-Reply-To: <20110727194722.GA9345@infradead.org>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan>
	 <20110727160752.GC974@fieldses.org>
	 <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan>
	 <20110727181111.GA23009@infradead.org>
	 <alpine.DEB.2.02.1107271530340.1451@p34.internal.lan>
	 <20110727193937.GA5354@infradead.org>
	 <alpine.DEB.2.02.1107271540100.1451@p34.internal.lan>
	 <20110727194722.GA9345@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311799021.25645.41.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 15:47 -0400, Christoph Hellwig wrote: 
> On Wed, Jul 27, 2011 at 03:44:20PM -0400, Justin Piszcz wrote:
> > 
> > 
> > On Wed, 27 Jul 2011, Christoph Hellwig wrote:
> > 
> > >On Wed, Jul 27, 2011 at 03:35:01PM -0400, Justin Piszcz wrote:
> > >>Currently I do not see any dupes, however I have a script that moves
> > >>images out of the directory once an hour:
> > >>0 * * * * /usr/local/bin/move_to_old2.sh > /dev/null 2>&1
> > >
> > >Do you keep adding files to the directory while you move files out?
> > Yes, otherwise there are too many files in the directory and viewers, e.g.,
> > each geeqie (picture viewer) will use > 4-6GB of memory, so I try to keep
> > it around 5,000 pictures or less.
> > 
> > >What's the rate of additions/removals to the directory?
> > Additions it depends, around 5,000 over a 12hr period, 416/hr, current:
> > 
> > atom:/d1/motion# find cam1|wc
> >    5215    5215  166853
> > atom:/d1/motion# find cam2|wc
> >    5069    5069  162181
> > atom:/d1/motion# find cam3|wc
> >    5594    5594  178981
> > atom:/d1/motion#
> 
> This sounds a lot like xfs simply filling up the directory index slots
> of files that you just moved out with new files, and nfs falsely
> claiming that this is a problem.

Yep. There is an existing bugzilla report for this bug at

   https://bugzilla.kernel.org/show_bug.cgi?id=38572

I have a preliminary patch there that attempts to turn off the loop
detection when the directory is seen to change, however that patch still
appears to have a bug in it, and I haven't had time to figure out what
is wrong yet.

Can you perhaps take a look, Bryan?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

