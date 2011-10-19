Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50252 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753176Ab1JSUBo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:01:44 -0400
Date: Wed, 19 Oct 2011 16:01:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount.nfs: mtab corruption when RLIMIT_FSIZE
 causes a partial write
Message-ID: <20111019200143.GB805@fieldses.org>
References: <1319038470-17750-1-git-send-email-steved@redhat.com>
 <20111019123626.7a80dfad@corrin.poochiereds.net>
 <4E9F047B.5000600@RedHat.com>
 <20111019132230.6cd85a0c@corrin.poochiereds.net>
 <4E9F0952.2040607@RedHat.com>
 <20111019173611.GC32028@fieldses.org>
 <4E9F1939.3030807@RedHat.com>
 <20111019195533.GA805@fieldses.org>
 <4E9F2C5F.8080103@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E9F2C5F.8080103@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 19, 2011 at 04:00:31PM -0400, Steve Dickson wrote:
> 
> 
> On 10/19/2011 03:55 PM, J. Bruce Fields wrote:
> > On Wed, Oct 19, 2011 at 02:38:49PM -0400, Steve Dickson wrote:
> >> This is the case. The following patch cause SIGXFSZ to be ignored.
> >>
> >> diff -up ./utils/mount/fstab.c.orig ./utils/mount/fstab.c
> >> --- ./utils/mount/fstab.c.orig	2011-10-19 13:28:57.318132000 -0400
> >> +++ ./utils/mount/fstab.c	2011-10-19 14:02:07.715039000 -0400
> >> @@ -387,8 +387,9 @@ lock_mtab (void) {
> >>  		sa.sa_flags = 0;
> >>  		sigfillset (&sa.sa_mask);
> >>    
> >> -		while (sigismember (&sa.sa_mask, ++sig) != -1
> >> -		       && sig != SIGCHLD) {
> > 
> > I'm very confused--the latest nfs-utils doesn't have this.
> > 
> > Oh, I see: it was fixed by b3e190c4adfc9ec47567c968bd000d282d07b05e
> > "mount: improve signal management when locking mtab".
> > 
> > So if you're working with an older version then you probably want to
> > backport that patch.
> Exactly... Read my last posting...  

I'm way behind!  Thanks--b.
