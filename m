Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34580 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752097AbdIVQXc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Sep 2017 12:23:32 -0400
Date: Fri, 22 Sep 2017 17:23:20 +0100
From: "Daniel P. Berrange" <berrange@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Matt Benjamin <mbenjami@redhat.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170922162320.GS12725@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange@redhat.com>
References: <20170919151051.GS9536@redhat.com>
 <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
 <20170919172452.GB29104@fieldses.org>
 <20170921170017.GK32364@stefanha-x1.localdomain>
 <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com>
 <1506079954.4740.21.camel@redhat.com>
 <CAKOnarmwR=ZTrKD-L8j8979_kowK+gr4jniQ1mA-d7tXZTS61w@mail.gmail.com>
 <1506083199.4740.38.camel@redhat.com>
 <20170922152855.GD13709@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20170922152855.GD13709@stefanha-x1.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 22, 2017 at 04:28:55PM +0100, Stefan Hajnoczi wrote:
> On Fri, Sep 22, 2017 at 08:26:39AM -0400, Jeff Layton wrote:
> > I'm not sure there is a strong one. I most just thought it sounded like
> > a possible solution here.
> > 
> > There's already a standard in place for doing RPC over AF_LOCAL, so
> > there's less work to be done there. We also already have AF_LOCAL
> > transport in the kernel (mostly for talking to rpcbind), so there's
> > helps reduce the maintenance burden there.
> > 
> > It utilizes something that looks like a traditional unix socket, which
> > may make it easier to alter other applications to use it. 
> > 
> > There's also a clear way to "firewall" this -- just don't mount hvsockfs
> > (or whatever), or don't build it into the kernel. No filesystem, no
> > sockets.
> > 
> > I'm not sure I'd agree about this being more restrictive, necessarily.
> > If we did this, you could envision eventually building something that
> > looks like this to a running host, but where the remote end is something
> > else entirely. Whether that's truly useful, IDK...
> 
> This approach where communications channels appear on the file system is
> similar to the existing virtio-serial device.  The guest driver creates
> a character device for each serial communications channel configured on
> the host.  It's a character device node though and not a UNIX domain
> socket.
> 
> One of the main reasons for adding virtio-vsock was to get native
> Sockets API communications that most applications expect (including
> NFS!).  Serial char device semantics are awkward.
> 
> Sticking with AF_LOCAL for a moment, another approach is for AF_VSOCK
> tunnel to the NFS traffic:
> 
>   (host)# vsock-proxy-daemon --unix-domain-socket path/to/local.sock
>                              --listen --port 2049
>   (host)# nfsd --local path/to/local.sock ...
> 
>   (guest)# vsock-proxy-daemon --unix-domain-socket path/to/local.sock
>                               --cid 2 --port 2049
>   (guest)# mount -t nfs -o proto=local path/to/local.sock /mnt
> 
> It has drawbacks over native AF_VSOCK support:
> 
> 1. Certain NFS protocol features become impossible to implement since
>    there is no meaningful address information that can be exchanged
>    between client and server (e.g. separate backchannel connection,
>    pNFS, etc).  Are you sure AF_LOCAL makes sense for NFS?
> 
> 2. Performance is worse due to extra proxy daemon.
> 
> If I understand correctly both Linux and nfs-utils lack NFS AF_LOCAL
> support although it is present in sunrpc.  For example, today
> fs/nfsd/nfsctl.c cannot add UNIX domain sockets.  Similarly, the
> nfs-utils nsfd program has no command-line syntax for UNIX domain
> sockets.
> 
> Funnily enough making AF_LOCAL work for NFS requires similar changes to
> the patches I've posted for AF_VSOCK.  I think AF_LOCAL tunnelling is a
> technically inferior solution than native AF_VSOCK support (for the
> reasons mentioned above), but I appreciate that it insulates NFS from
> AF_VSOCK specifics and could be used in other use cases too.

In the virt world using AF_LOCAL would be less portable than AF_VSOCK,
because AF_VSOCK is a technology implemented by both VMWare and KVM,
whereas an AF_LOCAL approach would likely be KVM only. In practice it
probably doesn't matter, since I doubt VMWare would end up using
NFS over AF_VSOCK, but conceptually I think AF_VSOCK makes more sense
for a virt scenario.

Using AF_LOCAL would not be solving the hard problems for virt like
migration either - it would just be hiding them under the carpet
and pretending they don't exist. Again preferrable to actually use
AF_VSOCK and define what the expected semantics are for migration.

Regards,
Daniel
-- 
|: https://berrange.com      -o-    https://www.flickr.com/photos/dberrange :|
|: https://libvirt.org         -o-            https://fstop138.berrange.com :|
|: https://entangle-photo.org    -o-    https://www.instagram.com/dberrange :|
