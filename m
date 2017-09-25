Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58174 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753788AbdIYIPC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Sep 2017 04:15:02 -0400
Date: Mon, 25 Sep 2017 09:14:52 +0100
From: "Daniel P. Berrange" <berrange@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Matt Benjamin <mbenjami@redhat.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170925081452.GA17374@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange@redhat.com>
References: <20170919164427.GV9536@redhat.com>
 <20170919172452.GB29104@fieldses.org>
 <20170921170017.GK32364@stefanha-x1.localdomain>
 <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com>
 <1506079954.4740.21.camel@redhat.com>
 <CAKOnarmwR=ZTrKD-L8j8979_kowK+gr4jniQ1mA-d7tXZTS61w@mail.gmail.com>
 <1506083199.4740.38.camel@redhat.com>
 <20170922152855.GD13709@stefanha-x1.localdomain>
 <20170922162320.GS12725@redhat.com>
 <AB9AE5F4-20EC-419D-838D-73BB42CEFCD6@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <AB9AE5F4-20EC-419D-838D-73BB42CEFCD6@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 22, 2017 at 02:31:56PM -0400, Chuck Lever wrote:
> 
> > On Sep 22, 2017, at 12:23 PM, Daniel P. Berrange <berrange@redhat.com> wrote:
> > 
> > On Fri, Sep 22, 2017 at 04:28:55PM +0100, Stefan Hajnoczi wrote:
> >> On Fri, Sep 22, 2017 at 08:26:39AM -0400, Jeff Layton wrote:
> >>> I'm not sure there is a strong one. I most just thought it sounded like
> >>> a possible solution here.
> >>> 
> >>> There's already a standard in place for doing RPC over AF_LOCAL, so
> >>> there's less work to be done there. We also already have AF_LOCAL
> >>> transport in the kernel (mostly for talking to rpcbind), so there's
> >>> helps reduce the maintenance burden there.
> >>> 
> >>> It utilizes something that looks like a traditional unix socket, which
> >>> may make it easier to alter other applications to use it. 
> >>> 
> >>> There's also a clear way to "firewall" this -- just don't mount hvsockfs
> >>> (or whatever), or don't build it into the kernel. No filesystem, no
> >>> sockets.
> >>> 
> >>> I'm not sure I'd agree about this being more restrictive, necessarily.
> >>> If we did this, you could envision eventually building something that
> >>> looks like this to a running host, but where the remote end is something
> >>> else entirely. Whether that's truly useful, IDK...
> >> 
> >> This approach where communications channels appear on the file system is
> >> similar to the existing virtio-serial device.  The guest driver creates
> >> a character device for each serial communications channel configured on
> >> the host.  It's a character device node though and not a UNIX domain
> >> socket.
> >> 
> >> One of the main reasons for adding virtio-vsock was to get native
> >> Sockets API communications that most applications expect (including
> >> NFS!).  Serial char device semantics are awkward.
> >> 
> >> Sticking with AF_LOCAL for a moment, another approach is for AF_VSOCK
> >> tunnel to the NFS traffic:
> >> 
> >> (host)# vsock-proxy-daemon --unix-domain-socket path/to/local.sock
> >>                            --listen --port 2049
> >> (host)# nfsd --local path/to/local.sock ...
> >> 
> >> (guest)# vsock-proxy-daemon --unix-domain-socket path/to/local.sock
> >>                             --cid 2 --port 2049
> >> (guest)# mount -t nfs -o proto=local path/to/local.sock /mnt
> >> 
> >> It has drawbacks over native AF_VSOCK support:
> >> 
> >> 1. Certain NFS protocol features become impossible to implement since
> >>  there is no meaningful address information that can be exchanged
> >>  between client and server (e.g. separate backchannel connection,
> >>  pNFS, etc).  Are you sure AF_LOCAL makes sense for NFS?
> >> 
> >> 2. Performance is worse due to extra proxy daemon.
> >> 
> >> If I understand correctly both Linux and nfs-utils lack NFS AF_LOCAL
> >> support although it is present in sunrpc.  For example, today
> >> fs/nfsd/nfsctl.c cannot add UNIX domain sockets.  Similarly, the
> >> nfs-utils nsfd program has no command-line syntax for UNIX domain
> >> sockets.
> >> 
> >> Funnily enough making AF_LOCAL work for NFS requires similar changes to
> >> the patches I've posted for AF_VSOCK.  I think AF_LOCAL tunnelling is a
> >> technically inferior solution than native AF_VSOCK support (for the
> >> reasons mentioned above), but I appreciate that it insulates NFS from
> >> AF_VSOCK specifics and could be used in other use cases too.
> > 
> > In the virt world using AF_LOCAL would be less portable than AF_VSOCK,
> > because AF_VSOCK is a technology implemented by both VMWare and KVM,
> > whereas an AF_LOCAL approach would likely be KVM only.
> 
> Is there a standard that defines the AF_VSOCK symbolic name and
> reserves a numeric value for it that can be used in a sockaddr?

The VMWare documentation for this feature is located here - they call
the overall feature either "vSockets" or "VMCI sockets":

   https://code.vmware.com/web/sdk/65/vmci-socket

In those code examples you'l see they never refer to AF_VSOCK directly
because the code is written from POV of a Windows developer, and IIUC
VMWare could not define a static AF_VSOCK constant for Windows. Instead
they show use of a function VMCISock_GetAFValue().

When VMWare implemented this for Linux they defined the AF_VSOCK constant,
and introduced the 'sockaddr_vm' struct for address info

commit d021c344051af91f42c5ba9fdedc176740cbd238
Author: Andy King <acking@vmware.com>
Date:   Wed Feb 6 14:23:56 2013 +0000

    VSOCK: Introduce VM Sockets
    
    VM Sockets allows communication between virtual machines and the hypervisor.
    User level applications both in a virtual machine and on the host can use the
    VM Sockets API, which facilitates fast and efficient communication between
    guest virtual machines and their host.  A socket address family, designed to be
    compatible with UDP and TCP at the interface level, is provided.
    
    Today, VM Sockets is used by various VMware Tools components inside the guest
    for zero-config, network-less access to VMware host services.  In addition to
    this, VMware's users are using VM Sockets for various applications, where
    network access of the virtual machine is restricted or non-existent.  Examples
    of this are VMs communicating with device proxies for proprietary hardware
    running as host applications and automated testing of applications running
    within virtual machines.
    
    The VMware VM Sockets are similar to other socket types, like Berkeley UNIX
    socket interface.  The VM Sockets module supports both connection-oriented
    stream sockets like TCP, and connectionless datagram sockets like UDP. The VM
    Sockets protocol family is defined as "AF_VSOCK" and the socket operations
    split for SOCK_DGRAM and SOCK_STREAM.
    
    For additional information about the use of VM Sockets, please refer to the
    VM Sockets Programming Guide available at:
    
    https://www.vmware.com/support/developer/vmci-sdk/
    
    Signed-off-by: George Zhang <georgezhang@vmware.com>
    Signed-off-by: Dmitry Torokhov <dtor@vmware.com>
    Signed-off-by: Andy king <acking@vmware.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


The KVM implementation was merged last year in Linux, simply using the
existing vSockets spec, but with a data transport using virtio. So any
standards that exist are actally those defined by VMWare - the only KVM
part is the use of virtio as a transport.

> > In practice it
> > probably doesn't matter, since I doubt VMWare would end up using
> > NFS over AF_VSOCK, but conceptually I think AF_VSOCK makes more sense
> > for a virt scenario.
> > 
> > Using AF_LOCAL would not be solving the hard problems for virt like
> > migration either - it would just be hiding them under the carpet
> > and pretending they don't exist. Again preferrable to actually use
> > AF_VSOCK and define what the expected semantics are for migration.
> 
> There's no hiding or carpets. We're just reviewing the various
> alternatives. AF_LOCAL has the same challenges as AF_VSOCK, as I've
> said in the past, except that it already has well-defined semantics,
> and it can be used in other environments besides host-guest.

The existing usage / other environments have no concept of migration, so
there is no defined behaviour for AF_LOCAL wrt guest migration. So my point
was that to use AF_LOCAL would be explicitly deciding to ignore the problem
of migration. Unless we define new semantics for AF_LOCAL wrt to migration,
in the same way we'd have to define those semantics for AF_VSOCK.

Regards,
Daniel
-- 
|: https://berrange.com      -o-    https://www.flickr.com/photos/dberrange :|
|: https://libvirt.org         -o-            https://fstop138.berrange.com :|
|: https://entangle-photo.org    -o-    https://www.instagram.com/dberrange :|
