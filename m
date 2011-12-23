Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752182Ab1LWREo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Dec 2011 12:04:44 -0500
Date: Fri, 23 Dec 2011 12:04:23 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org,
        steved@redhat.com
Subject: Re: [PATCH] nfsidmap: auto disable when keyutils is not found
Message-ID: <20111223120423.023d6a15@tlielax.poochiereds.net>
In-Reply-To: <20111223093401.52ad6812@tlielax.poochiereds.net>
References: <1314991015-21484-1-git-send-email-vapier@gentoo.org>
	<20111222093855.40112b8c@tlielax.poochiereds.net>
	<201112221120.12395.vapier@gentoo.org>
	<20111223093401.52ad6812@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 23 Dec 2011 09:34:01 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Thu, 22 Dec 2011 11:20:11 -0500
> Mike Frysinger <vapier@gentoo.org> wrote:
> 
> > On Thursday 22 December 2011 09:38:55 Jeff Layton wrote:
> > > On Fri,  2 Sep 2011 15:16:55 -0400 Mike Frysinger wrote:
> > > > --- a/aclocal/libnfsidmap.m4
> > > > +++ b/aclocal/libnfsidmap.m4
> > > > 
> > > > -  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], [enable_nfsidmap=yes],
> > > > -               [enable_nfsidmap=no])
> > > > +  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid])
> > > 
> > > The above delta in this patch has caused a build-time regression.
> > > 
> > > When you eliminated the 3rd argument to AC_CHECK_LIB, this started
> > > adding -lnfsidmap to $LIBS. That means that that library gets linked
> > > into every binary that's being built.
> > > 
> > > I haven't determined the right fix for this yet, but I think
> > > libnfsidmap.m4 could use some cleanup.
> > 
> > AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], [])
> > -mike
> 
> Uhhh, no. That turns the result of this test into a noop. We might as
> well remove it at that point.
> 
> Perhaps I should phrase this question differently: What is the above
> test supposed to achieve? IOW, what should happen if it passes or fails?
> 

Ahh nm, I think I see now...

We just need to ensure that $ac_cv_lib_nfsidmap_nfs4_owner_to_uid gets
set properly. If that's the case, then we probably want something like
this:

    AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], [:])

...autoconf treats bare brackets as if the argument weren't specified.
I have a patch that I'll pass along once I've done a bit of testing
with it.

-- 
Jeff Layton <jlayton@redhat.com>
