Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31312 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752233Ab1EBUVP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2011 16:21:15 -0400
Subject: Re: How does NFS handle notify?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Stef Bon <stefbon@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
In-Reply-To: <BANLkTi=2uYagwN=Xy9FxhXV4wt3tf669JA@mail.gmail.com>
References: <BANLkTi=X0VtcSecmEwzPBTqk3L154aj+2Q@mail.gmail.com>
	 <20110502140750.GA10885@fieldses.org>
	 <BANLkTinTu8XVmxkUUhJby8=DNY4sZF5VAQ@mail.gmail.com>
	 <1304347155.7830.7.camel@lade.trondhjem.org>
	 <BANLkTikZnnt0cmpP4iT4Q4EJTxZnSC_SYQ@mail.gmail.com>
	 <1304356699.7830.26.camel@lade.trondhjem.org>
	 <BANLkTi=2uYagwN=Xy9FxhXV4wt3tf669JA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 02 May 2011 16:21:13 -0400
Message-ID: <1304367673.20876.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-05-02 at 22:16 +0200, Stef Bon wrote:
> 2011/5/2 Trond Myklebust <Trond.Myklebust@netapp.com>:
> >> Next via a daemon like Gamin. Yes, possible, but is this smart? Isn't
> >> it just possible through the VFS like above described.
> >
> > All filesystems should already support notification for files that are
> > created through the VFS.
> 
> Exact, only I like to say here that the filesystems do not have to do
> anything for that.
> The VFS combines various things here. The filesystem self does not do
> anything here.
> 
> >
> > The missing bit is to support notification for files that are created on
> > the _server_ and that never go through the client VFS. That is precisely
> > the problem that projects such as FAM and gamin are supposed to solve
> > using generic userland daemons that can re-export the notifications from
> > the NFS/CIFS/... server to any interested listeners.
> 
> Yes that's also true. If you are taking nfs, cifs or a FUSE fs, where
> the server is for example the localhost self, thus more like backend.
> I 'm not very convinced Gamin is the way to go.
> 
> Let me explain:
> 
> for example a simple overlay FUSE fs, fusexmp-bind.
> It's behaving like a mount bind, making the contents of the directory
> to bind available under the mountpoint.
> 
> Now user a mounts it like:
> 
> mkdir ~/mount
> fusexmp-bind --bind-directory=/tmp ~/mount
> 
> This makes the directory /tmp available under ~/mount for user a.
> As you say, when the user does:
> 
> touch ~/mount/testfile1
> 
> any client watching the ~/mount directory (through notify) will be
> notfied of this change, while
> fusexmp-bind does not support inotify at all. It the VFS which does all that.
> 
> Now if any other process is doing something in /tmp,
> the same client watching ~/mount will not get notified, until a hard
> refresh command is given.
> The kernel (VFS) does not understand (and does not have to) that the
> directories /tmp and
> ~/mount are related.
> 
> A sollution is that the VFS makes the filesystem (in this case thus
> fusexmp-bind) aware of a client
> watching directory ~/mount.
> 
> This filesystem "knows" as the only one what to do with it, namenly
> set a inotify watch (with the same mask) on /tmp, read any events
> there and forward them back to the original inotify watch (the one on
> ~/mount).
> 
> I'm suggesting here the use of VFS, making the filesystem aware of an
> inotify watch.
> 
> But what about gamin?? Is is possible to make gamin take care of the
> changes, like with the simple example of above. Well, possible, but
> with extra configuration.
> And this is only a simple example. With much more complicated setups,
> where the files and directories a client "sees", which may depend on
> the specific context of that connection, Gamin cannot be aware af that
> all.
> 
> So my suggestion is to make everything go through the filesystem. As I
> mentioned above, the VFS should make the filesystem aware of a notify
> watch being added, the filesystem should take the right action (like
> sending a SMB2 CHANGE_NOTIFY Request to the server and wait for
> anything to come back from the server with cifs, or setting another
> intofy watch on the backend with the simple FUSE fs above, and with
> NFS doing something simular like cifs) and giving any received event
> back to the VFS.
> 
> There is another advantage here, which for my fs is interesting.
> "Knowing" that there is a watch set on a certain inode is interesting.
> My fs handles various resources, like local harddrives, usb sticks,
> cdroms but also SMB shares mounted with cifs, and especially with
> removable resources, like USB sticks and cdroms, it's very usefull
> that someone is watching it. This prevents it from unmounting it. But
> this counts for my fs.
> Ans also, it helps my fs to stay upto date. I say here helps, is not a
> complete garantee.
> 
> So, what's your opinion?

Your proposal requires NFS and CIFS protocol support and I just told you
that there is none in NFS...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

