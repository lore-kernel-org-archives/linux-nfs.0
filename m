Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1597 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752722Ab1IVRcQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 13:32:16 -0400
Date: Thu, 22 Sep 2011 13:35:29 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Ian Kent <raven@themaw.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        David Howells <dhowells@redhat.com>, miklos@szeredi.hu,
        viro@zeniv.linux.org.uk, gregkh@suse.de, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
Message-ID: <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
In-Reply-To: <1316709935.3346.48.camel@perseus.themaw.net>
References: <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
	<1316707443.3346.44.camel@perseus.themaw.net>
	<CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
	<1316709935.3346.48.camel@perseus.themaw.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 23 Sep 2011 00:45:35 +0800
Ian Kent <raven@themaw.net> wrote:

> On Thu, 2011-09-22 at 09:30 -0700, Linus Torvalds wrote:
> > On Thu, Sep 22, 2011 at 9:04 AM, Ian Kent <raven@themaw.net> wrote:
> > >
> > > I haven't checked what the side effects would be but using the
> > > LOOKUP_DIRECTORY flag in walks that get caught by the removal of the
> > > LOOKUP_FOLLOW test in follow_automount() and retaining Miklos's original
> > > patch is probably a more natural solution IMO.
> > 
> > Ok, I do have to agree with that.
> > 
> > So instead of adding a new flag, let's just document a few *logical*
> > rules for what causes auto-mounting:
> > 
> >  - opening the mount-point itself with LOOKUP_DIRECTORY does so
> > 
> >    Logic: when you use LOOKUP_DIRECTORY, you expect to see the
> > *contents* of the mount-point.
> > 
> >  - looking something up *under* the mount-point does so.
> > 
> >    This may be obvious, but it actually has a non-obvious special
> > case: what about the pathname "mountpoint" vs "mountpoint/"
> > 
> > And I think the "LOOKUP_DIRECTORY" rule ends up automatically also
> > resolving that special case: when we have a slash at the end of the
> > last component, it not only implies that we care about the contents,
> > it will also automatically set LOOKUP_DIRECTORY.
> > 
> > So I'm getting more and more convinced that LOOKUP_DIRECTORY is
> > actually the right thing to trigger on. It automatically means that
> > "opendir()" on the mountpoint will do the right thing (because
> > O_DIRECTORY results in LOOKUP_DIRECTORY), and it automatically - and
> > very naturally - gives user processes the ability to choose whether
> > they want to see auto-monting or not ("path" doesn't get auto-mounted,
> > but "path/" does).
> > 
> > Yet at the same time it keeps the "stupid default behavior for
> > processes that only look at each directory entry and don't even think
> > about automounting" be the "don't auto-mount when not necessary"
> > behavior.
> > 
> > So: no new flag. Just make nfs4 use LOOKUP_DIRECTORY, and let's add
> > big documentation notes about this.
> 
> Yes, that's what I think is best.
> 
> It's late here so I'll survey the code and see if I can find any other
> instances of this and post a patch, tomorrow.
> 
> Jeff, could you test adding LOOKUP_DIRECTORY to the walk in
> nfs_follow_remote_path() please, just in case I've got this all wrong.
> 

Yep, adding LOOKUP_DIRECTORY also fixes the problem. I'll go ahead and
send a patch to Trond...

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
