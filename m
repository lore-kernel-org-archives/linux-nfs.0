Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60559 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752844Ab2KHAVC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 19:21:02 -0500
Date: Wed, 7 Nov 2012 19:20:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Peter Staubach <pstaubach@exagrid.com>
Subject: Re: [PATCH 0/2] fix nfsd stable write implementation
Message-ID: <20121108002059.GA17945@fieldses.org>
References: <1351285617-20450-1-git-send-email-bfields@redhat.com>
 <20121030102833.306e833a@notabene.brown>
 <20121030140725.GC24618@fieldses.org>
 <20121031073027.254242ed@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121031073027.254242ed@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 31, 2012 at 07:30:27AM +1100, NeilBrown wrote:
> On Tue, 30 Oct 2012 10:07:25 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Tue, Oct 30, 2012 at 10:28:33AM +1100, NeilBrown wrote:
> > > On Fri, 26 Oct 2012 17:06:55 -0400 "J. Bruce Fields" <bfields@redhat.com>
> > > wrote:
> > > 
> > > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > > 
> > > > Peter pointed out to me that the nfs server is implementing stable
> > > > writes by setting the O_SYNC flag.  I can't see why we couldn't write
> > > > and then sync instead, but I don't know this stuff as well as I should;
> > > > does the following look reasonable to people?
> > > 
> > > Bruce changed the code to implement stable writes by calling
> > > vfs_fsync_range().  I can't see why we couldn't use O_SYNC instead.
> > > 
> > > It seems like you are making a change just for the sake of making a change.
> > > Is there some reason that you think a separate 'sync' is more efficient than
> > > using O_SYNC ?
> > 
> > Oh, sorry, see the changelog on the second patch: the problem is that
> > the struct file can be shared across multiple writes in the NFSv4 case,
> > so a single stable write could make all subsequent writes synchronous.
> > 
> > (And some day people would like filehandle caching for v2/v3, in which
> > case we'll run into the same problem.)
> 
> Ahh, I missed that.
> Makes sense then, thanks.
> 
> > 
> > > As a general principle, I think it is best to give the file system as much
> > > information as possible to that it can make whatever optimisation decisions
> > > that it wants to.
> > > 
> > > Setting O_SYNC gives the filesystem more information than not, because it
> > > allows it to change the behaviour of the 'write' request... though I don't
> > > know if any filesystem actually uses the information.
> > 
> > I'm not sure how to figure out if that's a real problem or not.
> 
> Search all filesystems for special handling of O_SYNC or O_DSYNC?
> 
> I strongly suspect that it is not a real problem.

OK, committing for 3.8.

--b.
