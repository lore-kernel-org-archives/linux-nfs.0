Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25200 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756757Ab3KNUfo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Nov 2013 15:35:44 -0500
Date: Thu, 14 Nov 2013 15:35:35 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org, neilb@suse.de,
        chuck.lever@oracle.com, steved@redhat.com
Subject: Re: [PATCH v2 0/3] sunrpc/nfs: more reliable detection of running
 gssd
Message-ID: <20131114153535.0cfec0c3@tlielax.poochiereds.net>
In-Reply-To: <20131114192601.GC21152@fieldses.org>
References: <1384353053-30002-1-git-send-email-jlayton@redhat.com>
	<20131114192601.GC21152@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 14 Nov 2013 14:26:01 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Nov 13, 2013 at 09:30:50AM -0500, Jeff Layton wrote:
> > v2:
> > - change name of toplevel pipefs dir from "dummy" to "gssd" (per
> >   Trond's suggestion)
> > 
> > - when gssd isn't running, don't bother to upcall (per Neil B.'s
> >   suggestion)
> > 
> > - fix lifecycle of rpc_pipe data. Previously it would have leaked
> >   after umount. With this set, it's created and destroyed along with
> >   the netns, and just attached to the pipe inode on mount/unmount
> >   of rpc_pipefs.
> > 
> > - patch has been added to skip attempting setclientid with krb5i
> >   if gssd isn't running. This avoids the "AUTH_GSS upcall timed out"
> >   message when gssd isn't running and you mount with sec=sys. It also
> >   shortens the delay when gssd isn't up.
> > 
> > The original cover letter from the v1 posting follows. Note that this
> > set does address the warnings about the AUTH_GSS upcall timing out.
> > 
> > -------------------------[snip]-----------------------------
> > 
> > We've gotten a lot of complaints recently about the 15s delay when
> > doing a sec=sys mount without gssd running.
> > 
> > A large part of the problem is that the kernel isn't able to reliably
> > detect when rpc.gssd is running. What we currently have is a
> > gssd_running flag that is initially set to 1. When an upcall times out,
> > that gets set to 0, and subsequent upcalls get a much shorter timeout
> > (1/4s instead of 15s). It's reset back to '1' when a pipe is reopened.
> > 
> > The approach of using a flag like this is pretty inadequate. First, it
> > doesn't eliminate the long delay on the initial upcall attempt. Also,
> > if gssd spontaneously dies, then the flag will still be set to 1 until
> > the next upcall attempt times out. Finally, it currently requires that
> > the pipe be reopened in order to reset the flag back to true.
> > 
> > This patchset replaces that flag with a more reliable mechanism for
> > detecting when gssd is running. When rpc_pipefs is mounted, it creates a
> > new "dummy" pipe that gssd will naturally find and hold open. We'll
> > never send an upcall down this pipe, and writing to it always fails.
> > But, since we can detect when something is holding it open, we can use
> > that to determine whether gssd is running.
> 
> I think this might have been addressed before, I don't remember: does
> the init system currently have a way to wait till gssd has gotten as far
> as scanning pipefs before allowing mounts?
> 
> (To avoid the race where a krb5 mount fails because gssd is still in the
> process of being started.)
> 
> --b.
> 

I don't think it does.

gssd forks (using daemon()) before it does any real work, and then the
parent exits. I imagine it's possible to hit such a race.

Personally, I've never seen it happen in practice, and I have tested
sec=krb5 mounts in /etc/fstab on recent Fedora. That may just be a
matter of timing or of enough stuff running between rpc.gssd and the
mounts being done.

It might not hurt to patch gssd so that the parent delays exiting until
the child starts up and does its initial run in the !fg case...

-- 
Jeff Layton <jlayton@redhat.com>
