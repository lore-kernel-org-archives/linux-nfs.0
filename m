Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:53160 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdKITsV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Nov 2017 14:48:21 -0500
Received: by mail-oi0-f43.google.com with SMTP id r128so5257905oig.9
        for <linux-nfs@vger.kernel.org>; Thu, 09 Nov 2017 11:48:21 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
Message-ID: <1510256899.2495.20.camel@gmail.com>
Subject: Re: NFS Force Unmounting
To: Trond Myklebust <trondmy@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>,
        "neilb@suse.com" <neilb@suse.com>
Cc: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>
Date: Thu, 09 Nov 2017 13:48:19 -0600
In-Reply-To: <1510185172.9891.18.camel@primarydata.com>
References: <1508951506.2542.51.camel@gmail.com>
         <20171030202045.GA6168@fieldses.org>
         <87h8ugwdev.fsf@notabene.neil.brown.name>
         <1509557061.4755.27.camel@redhat.com>
         <87efphvbhy.fsf@notabene.neil.brown.name>
         <1509624549.4569.28.camel@redhat.com>
         <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
         <87fu9ph2g7.fsf@notabene.neil.brown.name>
         <1510142905.8401.6.camel@redhat.com> <20171108155203.GK24262@fieldses.org>
         <87wp30flgs.fsf@notabene.neil.brown.name>
         <1510185172.9891.18.camel@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-11-08 at 23:52 +0000, Trond Myklebust wrote:
> On Thu, 2017-11-09 at 09:34 +1100, NeilBrown wrote:
> > On Wed, Nov 08 2017, J. Bruce Fields wrote:
> > 
> > > On Wed, Nov 08, 2017 at 07:08:25AM -0500, Jeff Layton wrote:
> > > > On Wed, 2017-11-08 at 14:30 +1100, NeilBrown wrote:
> > > > > What to people think of the following as an approach
> > > > > to Joshua's need?
> > > > > 
> > > > > It isn't complete by itself: it needs a couple of changes to
> > > > > nfs-utils so that it doesn't stat the mountpoint on remount,
> > > > > and it might need another kernel change so that the "mount"
> > > > > system
> > > > > call performs the same sort of careful lookup for remount
> > > > > as  the umount
> > > > > system call does, but those are relatively small details.
> > > > > 
> > > > 
> > > > Yeah, that'd be good.
> > > > 
> > > > > This is the patch that you will either love of hate.
> > > > > 
> > > > > With this patch, Joshua (or any other sysadmin) could:
> > > > > 
> > > > >   mount -o remount,retrans=0,timeo=1 /path
> > > > > 
> > > > > and then new requests on any mountpoint from that server will
> > > > > timeout
> > > > > quickly.
> > > > > Then
> > > > >   umount -f /path
> > > > >   umount -f /path
> > > 
> > > ...
> > > > Looks like a reasonable approach overall to preventing new RPCs
> > > > from
> > > > being dispatched once the "force" umount runs.
> > > 
> > > I've lost track of the discussion--after this patch, how close
> > > are
> > > we to
> > > a guaranteed force unmount?  I assume there are still a few
> > > obstacles.
> > 
> > This isn't really about forced unmount.
> > The way forward to forced unmount it:
> >  - make all waits on NFS be TASK_KILLABLE
> >  - figure out what happens to dirty data when all processes have
> >    been killed.
> > 
> > This is about allowing processes to be told that the filesystem is
> > dead
> > so that can respond (without blocking indefinitely) without
> > necessarily being killed.
> > With a local filesystem you can (in some cases) kill the underlying
> > device and all processes will start getting EIO.  This is providing
> > similar functionality for NFS.
> > 
> > > 
> > > > I do wonder if this ought to be more automatic when you specify
> > > > -f on
> > > > the umount. Having to manually do a remount first doesn't seem
> > > > very
> > > > admin-friendly.
> > > 
> > > It's an odd interface.  Maybe we could wrap it in something more
> > > intuitive.
> > > 
> > > I'd be nervous about making "umount -f" do it.  I think
> > > administrators
> > > could be unpleasantly surprised in some cases if an "umount -f"
> > > affects
> > > other mounts of the same server.
> > 
> > I was all set to tell you that it already does, but then tested and
> > found it doesn't and ....

I tried mounting two different remote paths from an NFS4 server, and
when I did 'remount,retrans=0', it changed the parameter for both of
them meaning they are indeed shaing the struct nfs_server (which based
on my reading of the code is what I would have expected). What
procedure did you use to test this?

> > 
> > struct nfs_server (which sb->s_fs_info points to) contains
> > 
> > 	struct nfs_client *	nfs_client;	/* shared client
> > and NFS4 state */
> > 
> > which is shared between different mounts from the same server, and
> > 
> > 	struct rpc_clnt *	client;		/* RPC client
> > handle */
> > 
> > which isn't shared.
> > struct nfs_client contains
> > 	struct rpc_clnt *	cl_rpcclient;
> > 
> > which server->client is clones from.
> > 
> > The timeouts that apply to a mount are the ones from server-
> > >client,
> > and so apply only to that mount (I thought they were shared, but
> > that
> > is
> > a thought from years ago, and maybe it was wrong at the time).
> > umount_begin aborts all rpcs associated with server->client.
> > 
> > So the 'remount,retrans=0,timeo=1' that I propose would only affect
> > the
> > one superblock (all bind-mounts of course, included sharecache
> > mounts).
> > 
> > The comment in my code was wrong.
> > 
> 
> I by far prefer an operation that changes the superblock state to be
> done using 'mount -o remount'. The idea of a 'umount -f' that makes
> the
> superblock irreversibly change state is clearly not desirable in an
> environment where the same superblock could be bind mounted and/or
> mounted in multiple private namespaces.
> 
> IOW: 'remount,retrans=0,timeo=1' would be slightly preferable to
> hacking up "umount -f" because it is reversible.
> 
> That said, there is no reason why we couldn't implement a single
> mount
> option that implements something akin to this "umount -f" behaviour
> (and that can be reversed by resetting it through a second
> 'remount').
> It seems to me that the requested behaviour is already pretty close
> to
> what we already implement with the RPC_TASK_SOFTCONN option.

I *think* my patch series pretty much does just that (not via
RPC_TASK_SOFTCONN). I might have broken the thread by posting with the
wrong parent... anyway you find can find them here: http://www.spinics.
net/lists/linux-nfs/msg66348.html. 

I added support for toggling the forcekill flag via remount, which I
think might be close to what you are looking for, e.g. if you mount
without the forcekill option, umount -f does what it always has. You
can then "-o remount,forcekill" and umount -f will cause all RPC tasks
to fail with -EIO. The number of patches has grown, so I currently have
this on a GitHub branch (including Neil's patch for testing): https://g
ithub.com/JPEWdev/linux/tree/sunrpc-kill, but I can send them to the
list if that would be helpful.

Using a changable mount option is fine, but it does mean that the
option again applies to all mounts from the same server (at least as
far as I can understand: I could be wrong and Neil could be right - see
above). Choosing the behavior at mount time (and not allowing it to
change after) has the advantage that you can choose which mounts it
applies to and which it doesn't. Although, I suppose if you really
wanted that behavior, you should be mounting with "nosharecache"
anyway?

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com

Thanks,
Joshua Watt
