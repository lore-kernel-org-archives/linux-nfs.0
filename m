Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:43948 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752196AbdIVM0m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Sep 2017 08:26:42 -0400
Received: by mail-qt0-f171.google.com with SMTP id i50so844880qtf.0
        for <linux-nfs@vger.kernel.org>; Fri, 22 Sep 2017 05:26:42 -0700 (PDT)
Message-ID: <1506083199.4740.38.camel@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
From: Jeff Layton <jlayton@redhat.com>
To: Matt Benjamin <mbenjami@redhat.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Daniel P. Berrange" <berrange@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Justin Mitchell <jumitche@redhat.com>
Date: Fri, 22 Sep 2017 08:26:39 -0400
In-Reply-To: <CAKOnarmwR=ZTrKD-L8j8979_kowK+gr4jniQ1mA-d7tXZTS61w@mail.gmail.com>
References: <DE7FAAE5-26F5-4B11-A83D-F74C9B7D81FB@oracle.com>
         <20170915164223.GE23557@fieldses.org>
         <A1844833-18E1-4F03-BB20-A06A6FE4AB62@oracle.com>
         <20170918180927.GD12759@stefanha-x1.localdomain>
         <20170919093140.GF9536@redhat.com>
         <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com>
         <20170919151051.GS9536@redhat.com>
         <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
         <20170919164427.GV9536@redhat.com> <20170919172452.GB29104@fieldses.org>
         <20170921170017.GK32364@stefanha-x1.localdomain>
         <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com>
         <1506079954.4740.21.camel@redhat.com>
         <CAKOnarmwR=ZTrKD-L8j8979_kowK+gr4jniQ1mA-d7tXZTS61w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm not sure there is a strong one. I most just thought it sounded like
a possible solution here.

There's already a standard in place for doing RPC over AF_LOCAL, so
there's less work to be done there. We also already have AF_LOCAL
transport in the kernel (mostly for talking to rpcbind), so there's
helps reduce the maintenance burden there.

It utilizes something that looks like a traditional unix socket, which
may make it easier to alter other applications to use it. 

There's also a clear way to "firewall" this -- just don't mount hvsockfs
(or whatever), or don't build it into the kernel. No filesystem, no
sockets.

I'm not sure I'd agree about this being more restrictive, necessarily.
If we did this, you could envision eventually building something that
looks like this to a running host, but where the remote end is something
else entirely. Whether that's truly useful, IDK...

-- Jeff

On Fri, 2017-09-22 at 08:08 -0400, Matt Benjamin wrote:
> This version of AF_LOCAL just looks like VSOCK and vhost-vsock, by
> another name.  E.g., it apparently hard-wires VSOCK's host-guest
> communication restriction even more strongly.  What are its intrinsic
> advantages?
> 
> Matt
> 
> On Fri, Sep 22, 2017 at 7:32 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > On Fri, 2017-09-22 at 10:55 +0100, Steven Whitehouse wrote:
> > > Hi,
> > > 
> > > 
> > > On 21/09/17 18:00, Stefan Hajnoczi wrote:
> > > > On Tue, Sep 19, 2017 at 01:24:52PM -0400, J. Bruce Fields wrote:
> > > > > On Tue, Sep 19, 2017 at 05:44:27PM +0100, Daniel P. Berrange wrote:
> > > > > > On Tue, Sep 19, 2017 at 11:48:10AM -0400, Chuck Lever wrote:
> > > > > > > > On Sep 19, 2017, at 11:10 AM, Daniel P. Berrange <berrange@redhat.com> wrote:
> > > > > > > > VSOCK requires no guest configuration, it won't be broken accidentally
> > > > > > > > by NetworkManager (or equivalent), it won't be mistakenly blocked by
> > > > > > > > guest admin/OS adding "deny all" default firewall policy. Similar
> > > > > > > > applies on the host side, and since there's separation from IP networking,
> > > > > > > > there is no possibility of the guest ever getting a channel out to the
> > > > > > > > LAN, even if the host is mis-configurated.
> > > > > > > 
> > > > > > > We don't seem to have configuration fragility problems with other
> > > > > > > deployments that scale horizontally.
> > > > > > > 
> > > > > > > IMO you should focus on making IP reliable rather than trying to
> > > > > > > move familiar IP-based services to other network fabrics.
> > > > > > 
> > > > > > I don't see that ever happening, except in a scenario where a single
> > > > > > org is in tight control of the whole stack (host & guest), which is
> > > > > > not the case for cloud in general - only some on-site clouds.
> > > > > 
> > > > > Can you elaborate?
> > > > > 
> > > > > I think we're having trouble understanding why you can't just say "don't
> > > > > do that" to someone whose guest configuration is interfering with the
> > > > > network interface they need for NFS.
> > > > 
> > > > Dan can add more information on the OpenStack use case, but your
> > > > question is equally relevant to the other use case I mentioned - easy
> > > > file sharing between host and guest.
> > > > 
> > > > Management tools like virt-manager (https://virt-manager.org/) should
> > > > support a "share directory with VM" feature.  The user chooses a
> > > > directory on the host, a mount point inside the guest, and then clicks
> > > > OK.  The directory should appear inside the guest.
> > > > 
> > > > VMware, VirtualBox, etc have had file sharing for a long time.  It's a
> > > > standard feature.
> > > > 
> > > > Here is how to implement it using AF_VSOCK:
> > > > 1. Check presence of virtio-vsock device in VM or hotplug it.
> > > > 2. Export directory from host NFS server (nfs-ganesha, nfsd, etc).
> > > > 3. Send qemu-guest-agent command to (optionally) add /etc/fstab entry
> > > >     and then mount.
> > > > 
> > > > The user does not need to take any action inside the guest.
> > > > Non-technical users can share files without even knowing what NFS is.
> > > > 
> > > > There are too many scenarios where guest administrator action is
> > > > required with NFS over TCP/IP.  We can't tell them "don't do that"
> > > > because it makes this feature unreliable.
> > > > 
> > > > Today we ask users to set up NFS or CIFS themselves.  In many cases that
> > > > is inconvenient and an easy file sharing feature would be much better.
> > > > 
> > > > Stefan
> > > > 
> > > 
> > > I don't think we should give up on making NFS easy to use with TCP/IP in
> > > such situations. With IPv6 we could have (for example) a device with a
> > > well known link-local address at the host end, and an automatically
> > > allocated link-local address at the guest end. In other words the same
> > > as VSOCK, but with IPv6 rather than VSOCK addresses. At that point the
> > > remainder of the NFS config steps would be identical to those you've
> > > outlined with VSOCK above.
> > > 
> > > Creating a (virtual) network device which is restricted to host/guest
> > > communication and automatically configures itself should be a lot less
> > > work than adding a whole new protocol to NFS I think. It could also be
> > > used for many other use cases too, as well as giving the choice between
> > > NFS and CIFS. So it is much more flexible, and should be quicker to
> > > implement too,
> > > 
> > 
> > FWIW, I'm also intrigued by Chuck's AF_LOCAL proposition. What about
> > this idea:
> > 
> > Make a filesystem (or a pair of filesystems) that could be mounted on
> > host and guest. Application running on host creates a unix socket in
> > there, and it shows up on the guest's filesystem. The sockets use a
> > virtio backend to shuffle data around.
> > 
> > That seems like it could be very useful.
> > --
> > Jeff Layton <jlayton@redhat.com>
> 
> 
> 

-- 
Jeff Layton <jlayton@redhat.com>
