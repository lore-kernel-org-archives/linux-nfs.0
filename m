From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol for mount.
Date: Sun, 20 Jul 2008 16:48:39 +1000
Message-ID: <18562.57287.656749.540603@notabene.brown>
References: <18556.40594.897682.204554@notabene.brown>
	<76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
	<18559.53893.95829.499988@notabene.brown>
	<76bd70e30807190909n12b9f70an87ccb62198c3a7d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37945 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754695AbYGTGsr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Jul 2008 02:48:47 -0400
In-Reply-To: message from Chuck Lever on Saturday July 19
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday July 19, chuck.lever@oracle.com wrote:
> > Suppose we were to take this approach:
> >
> >   mount.nfs does DNS lookup and portmap look to find IP address and
> >      port number.  However it *doesn't* send a 'clnt_ping' as
> >      probe_port currently does.
> >   The information it collects is explicitly given to the kernel with
> >       mountproto= mountport= etc.
> >   The kernel talks directly to mountd (given proto/addr/port) to get
> >      the filehandle and so forth.  It doesn't talk to portmap at all
> >      if it is given the required port numbers.
> >
...
> >
> > Thoughts?
> 
> Using a connected UDP socket for both the kernel's rpcbind and it's
> mountd client could help in many cases, including, probably, the one
> you mention below, without the need for changing the current
> architecture.
> 
> One thing about explicitly specifying mountport and mountproto during
> a mount is that the umount.nfs command may have to include some logic
> to throw those out and reprobe if those settings don't work at unmount
> time.  These options were added to allow traversing a firewall using a
> fixed port and protocol; overloading them for the case you describe
> above may perhaps have some unpleasant consequences for the fixed
> port/protocol case.
> 

Yes....  umount wouldn't know the difference between:
  - don't use portmap, it doesn't work.  Just use this port number.
and
  - I used portmap and got this port number, so maybe it will be
    useful to you to.

In the first case umount should only use the mountport given.  In the
second case it arguably should not and should always talk to portmap
to get he port number (as it could be much later and mountd may well
be on a different port).


> >> > If an NFS server is only listening on TCP for portmap (as apparently
> >> > MS-Windows-Server2003R2SP2 does), mount doesn't cope.  There is retry
> >> > logic in case the initial choice of version/etc doesn't work, but it
> >> > doesn't cope with mountd needing tcp.
> 
> I think that is mostly because the text-based mount option rewriting
> logic isn't robust yet.  I have several patches in the IPv6 series
> that should address some of this.

Any chance of pulling these out and sending them upstream now?  or is
the IPv6 series very close to release?

> 
> But many of Linux's NFS auxiliary services are UDP-only.  statd and
> sm-notify, for instance, are UDP-only as far as I can tell.  And
> recently the kernel's NLM service was changed to listen only on TCP if
> clients are connecting to servers only via TCP -- and that breaks some
> local Linux services that assume UDP will always be there (like
> SM_MON).

I'm not so much focussed on "make it work without UDP" as "avoid a
regression".  The current code doesn't work in situations where the
old code does work.  That is bad.

NLM without UDP has probably never worked for exactly the reasons you
mention, so it is not clear that anything needs to be "fixed" there.

I'd just like to get the regression fixed.

Thanks,
NeilBrown
