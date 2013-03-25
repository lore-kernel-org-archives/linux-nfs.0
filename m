Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46745 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933598Ab3CYXgv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 19:36:51 -0400
Date: Mon, 25 Mar 2013 19:36:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountd: regression in crossmounts
Message-ID: <20130325233649.GF10887@fieldses.org>
References: <1364049149-3751-1-git-send-email-steved@redhat.com>
 <20130325181314.GA10120@fieldses.org>
 <5150B1FD.1070405@RedHat.com>
 <20130325212736.GC10887@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130325212736.GC10887@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 25, 2013 at 05:27:36PM -0400, J. Bruce Fields wrote:
> On Mon, Mar 25, 2013 at 04:22:21PM -0400, Steve Dickson wrote:
> > 
> > 
> > On 25/03/13 14:13, J. Bruce Fields wrote:
> > > On Sat, Mar 23, 2013 at 10:32:29AM -0400, Steve Dickson wrote:
> > >> commit 8e2fb3fc cause a regression in mount export
> > >> that are on different local file system.
> > >> Exports like (all on different filesystems)
> > >>
> > >> /home *(rw,fsid=0,crossmnt)
> > >> /home/fs1 *(rw,crossmnt)
> > >> /home/fs1/fs2/fs3 *(rw,nohide)
> > >>
> > >> and then a mount of the root 'mount /home /mnt'
> > >> would end up mounting /home/fs1/fs2/fs3 not /home
> > > 
> > > That's strange.
> > Yeah... I had this guy reporting from day one that the 
> > latest nfs-utils broke his export world... 
> >  
> > > 
> > >> Reverting the logic of commit 8e2fb3fc until
> > >> a better solution can be found for the original
> > >> problem.
> > > 
> > > I can't figure out why the patch below would help.  The only change I
> > > can see is to the way that an export of "/" would be handled.
> > The reason I didn't debug this further was I did not know how to 
> > reproduce the original problem the patch was trying to fix... 
> 
> Could you remind me where the bug report for this is?

Oh, right, it was https://bugzilla.redhat.com/show_bug.cgi?id=909882

I'm not seeing why you think this helps.

--b.
