Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28082 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131Ab1IVP3v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 11:29:51 -0400
Date: Thu, 22 Sep 2011 11:33:06 -0400
From: Jeff Layton <jlayton@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, miklos@szeredi.hu,
        raven@themaw.net, viro@zeniv.linux.org.uk, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] NFS4: Revert commit to make the automount code ignore
 LOOKUP_FOLLOW
Message-ID: <20110922113306.1a831043@barsoom.rdu.redhat.com>
In-Reply-To: <6490.1316704925@redhat.com>
References: <CA+55aFzoH2VxTvf3Q1Lp_GAqDNAbsSOa=ATFXYSmmM=K8Fhuew@mail.gmail.com>
	<20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
	<6490.1316704925@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 22 Sep 2011 16:22:05 +0100
David Howells <dhowells@redhat.com> wrote:

> 
> One thing that does concern me a little about bringing back the old behaviour
> for stat and *xattr is that there is no reliable way to get at the directory
> mounted directly on the mountpoint (ie. mnt_root).
> 
> The problem is that:
> 
>  (a) you have to know to trigger the automount with some other operation first
>      and
> 
>  (b) the other operation is not atomic wrt to the following stat/xattr, and so
>      the thing mounted on the automount point may be subject to expiration and
>      auto-unmounting before the second operation can proceed.
> 
> I'm not sure how much of a problem these are in practice.  Certainly, I'd rate
> (b) as being less serious than (a) as the expiration timeouts are generally
> quite large.  (b) can be suppressed with chdir() or open() also - then you are
> forcing retension of the vfsmount.
> 
> The problem can be ameliorated for such as fstatat() by passing an AT_ flag to
> either suppress automounting or to force automounting, but there aren't any
> xattr calls, for example, that take this.
> 
> 
> I guess it comes down to defining two things:
> 
>  (1) What behaviour do we actually want?
> 
>  (2) What departure from previous behaviour are we willing to put up with?
> 
> 
> On the first, I would say definitely we want mass-stat'ers (such as ls) to not
> cause mass automounting.  But for ls, that has been achieved in userspace;
> there are, however, other programs to consider.
> 
> I would also say that we do not want lstat(), l*xattr() and co. to cause
> automounting - but maybe they should.  Perhaps if you don't want to cause
> automounting, you should explicitly pass AT_NO_AUTOMOUNT, and all path-taking
> VFS calls should have variants that accept this flag.
> 
> Do we want to have guaranteed access to the root of an automounted fs?  Are we
> willing to add getxattrat and similar to get it?
> 

I guess we recognize that we ought to allow userspace to have some
control over whether these syscalls will trigger an automount. So the
real question is -- what should the default be? Probably, we ought to
err on the side of caution and keep the default behavior the way it was
before 2.6.38.

-- 
Jeff Layton <jlayton@redhat.com>
