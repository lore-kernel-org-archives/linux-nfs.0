Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:49907 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757679AbaD2PMS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 11:12:18 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Jeff Layton'" <jlayton@poochiereds.net>,
        "'Matt W. Benjamin'" <matt@linuxbox.com>
Cc: "'Ganesha NFS List'" <nfs-ganesha-devel@lists.sourceforge.net>,
        "'lkml'" <linux-kernel@vger.kernel.org>,
        "'Linux-Fsdevel'" <linux-fsdevel@vger.kernel.org>,
        "'Trond Myklebust'" <trond.myklebust@fys.uio.no>,
        "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Neil Brown'" <neilb@suse.de>, <samba-technical@lists.samba.org>,
        <linux-nfs@vger.kernel.org>,
        "'Michael Kerrisk \(man-pages\)'" <mtk.manpages@gmail.com>
References: <20140429071153.176c7404@tlielax.poochiereds.net>	<1482413734.4.1398771608019.JavaMail.root@thunderbeast.private.linuxbox.com> <20140429075046.39fc9c3f@tlielax.poochiereds.net>
In-Reply-To: <20140429075046.39fc9c3f@tlielax.poochiereds.net>
Subject: RE: OFD ("file private") locks and NFS
Date: Tue, 29 Apr 2014 08:11:27 -0700
Message-ID: <030601cf63bd$4c635220$e529f660$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Tue, 29 Apr 2014 07:40:08 -0400 (EDT) "Matt W. Benjamin"
> <matt@linuxbox.com> wrote:
> 
> > Hi Jeff,
> >
> > Something which came up on the last Ganesha conn call is that we have
> > a pretty strong need for some ability to wait on a set of locks, and
> > perhaps receive events.  Frank Filz believed that you had made a
> > proposal which would cover this.  Can you elaborate on that?
> >
> > Thanks,
> >
> > Matt
> >
> 
> No, there's no mechanism to wait on a set of locks from within the context
of
> a single thread of execution or to receive "events". Again, that would be
a
> new API beyond what I've been proposing over the last several months.

Some kind of facility to enable one user space thread to wait on multiple
blocked locks would definitely be helpful to user space servers.

Our current plan is to have a pool of threads, and dispatch blocking locks
to them. If that pool is exhausted, all further locks would be dispatched to
a single thread that would poll for locks.

Frank


