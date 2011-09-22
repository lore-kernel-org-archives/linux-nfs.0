Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33512 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712Ab1IVPWx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 11:22:53 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CA+55aFzoH2VxTvf3Q1Lp_GAqDNAbsSOa=ATFXYSmmM=K8Fhuew@mail.gmail.com>
References: <CA+55aFzoH2VxTvf3Q1Lp_GAqDNAbsSOa=ATFXYSmmM=K8Fhuew@mail.gmail.com> <20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, miklos@szeredi.hu, raven@themaw.net,
        viro@zeniv.linux.org.uk, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] NFS4: Revert commit to make the automount code ignore LOOKUP_FOLLOW
Date: Thu, 22 Sep 2011 16:22:05 +0100
Message-ID: <6490.1316704925@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


One thing that does concern me a little about bringing back the old behaviour
for stat and *xattr is that there is no reliable way to get at the directory
mounted directly on the mountpoint (ie. mnt_root).

The problem is that:

 (a) you have to know to trigger the automount with some other operation first
     and

 (b) the other operation is not atomic wrt to the following stat/xattr, and so
     the thing mounted on the automount point may be subject to expiration and
     auto-unmounting before the second operation can proceed.

I'm not sure how much of a problem these are in practice.  Certainly, I'd rate
(b) as being less serious than (a) as the expiration timeouts are generally
quite large.  (b) can be suppressed with chdir() or open() also - then you are
forcing retension of the vfsmount.

The problem can be ameliorated for such as fstatat() by passing an AT_ flag to
either suppress automounting or to force automounting, but there aren't any
xattr calls, for example, that take this.


I guess it comes down to defining two things:

 (1) What behaviour do we actually want?

 (2) What departure from previous behaviour are we willing to put up with?


On the first, I would say definitely we want mass-stat'ers (such as ls) to not
cause mass automounting.  But for ls, that has been achieved in userspace;
there are, however, other programs to consider.

I would also say that we do not want lstat(), l*xattr() and co. to cause
automounting - but maybe they should.  Perhaps if you don't want to cause
automounting, you should explicitly pass AT_NO_AUTOMOUNT, and all path-taking
VFS calls should have variants that accept this flag.

Do we want to have guaranteed access to the root of an automounted fs?  Are we
willing to add getxattrat and similar to get it?

David
