Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:35422 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756123AbdEROIB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 May 2017 10:08:01 -0400
Received: by mail-qk0-f176.google.com with SMTP id a72so36471688qkj.2
        for <linux-nfs@vger.kernel.org>; Thu, 18 May 2017 07:07:41 -0700 (PDT)
Message-ID: <1495116454.3956.4.camel@redhat.com>
Subject: Re: [PATCH 0/4] nfs-utils mount: add AF_VSOCK support
From: Jeff Layton <jlayton@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 18 May 2017 10:07:34 -0400
In-Reply-To: <20170518124830.GA4155@stefanha-x1.localdomain>
References: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
         <1495039891.2930.8.camel@redhat.com>
         <20170518124830.GA4155@stefanha-x1.localdomain>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-05-18 at 13:48 +0100, Stefan Hajnoczi wrote:
> On Wed, May 17, 2017 at 12:51:31PM -0400, Jeff Layton wrote:
> > On Fri, 2016-10-07 at 11:01 +0100, Stefan Hajnoczi wrote:
> > > The AF_VSOCK address family allows virtual machines to communicate with the
> > > hypervisor using a zero-configuration transport.  Both KVM and VMware
> > > hypervisors support AF_VSOCK and it was introduced in Linux 3.9.
> > > 
> > > This patch series adds AF_VSOCK support to mount.nfs(8) and works together with
> > > the kernel NFS client patches that I am also posting to
> > > linux-nfs@vger.kernel.org.
> > > 
> > > NFS over AF_VSOCK is useful for file system sharing between a virtual machine
> > > and the host.  Due to the zero-configuration nature of AF_VSOCK this is more
> > > transparent to the user and more robust than asking the user to set up NFS over
> > > TCP/IP.
> > > 
> > > A file system from the host (hypervisor) can be mounted inside a virtual
> > > machine over AF_VSOCK like this:
> > > 
> > >   (guest)# mount.nfs 2:/export /mnt -v -o clientaddr=3,proto=vsock
> > > 
> > > The VM's cid (address) is 3 and the hypervisor is 2.
> > > 
> > 
> > Sorry for the long delay, and I may just not have been keeping up. I'd
> > like to start taking a look at these patches, but I'm having a hard time
> > finding much information about how one would use AF_VSOCK in practice.
> > I'd like to understand the general idea a little more before I go
> > reviewing code...
> > 
> > If 2 is always the HV's address, then is that documented somewhere?
> 
> Yes, it's always the address for the host.  In
> /usr/include/linux/vm_sockets.h:
> 
>   /* Use this as the destination CID in an address when referring to the host
>    * (any process other than the hypervisor).  VMCI relies on it being 2, but
>    * this would be useful for other transports too.
>    */
> 
>   #define VMADDR_CID_HOST 2
> 
> VMCI is VMware's AF_VSOCK transport.  virtio-vsock is the VIRTIO
> transport for AF_VSOCK (used by KVM).
> 
> > How are guest addresses determined?
> 
> Guest addresses are assigned before launching a VM.  They are
> re-assigned upon live migration (they have host-wide scope, not
> datacenter scope).
> 
> KVM (QEMU) virtual machines are typically managed using libvirt.
> Libvirt support for AF_VSOCK is currently in development and it will
> assign addresses to guests.
> 

Ok...is there some way for the guest to determine its own cid
programmatically? 

> > Can different guests talk to each other over vsock?
> 
> No, for security reasons this is purely host<->guest.  The protocol is
> not routable and guest<->guest communication is forbidden.
> 

Pity...that seems like it could have made this more useful.

Are there plans to eventually add some sort of name resolution? (It
> > might be interesting to put together a NSS module that keeps a list of
> > running guest hostnames and their vsock addresses).
> 
> Not at this time.

Yeah, not much point in it if it's always between guest and hv.

Ok, so this is really just allows a guest to mount a server running on
the bare metal host os? I guess you could also do it the other way
around too, but that doesn't seem terribly useful.

Other than the reliable way to know what the HV's VSOCK address is,
what's the compelling reason to do this? I guess you might be able to
get more reliable root on NFS with this, but if the server has to be
running on the same physical box then why not present a disk image in
another way and get NFS out of the picture?

Note that AF_VSOCK itself seems quite useful for certain guest->host
communications. I just don't quite grok why I'd want to use this over
vanilla IP networking for NFS as it doesn't seem quite as flexible.
-- 
Jeff Layton <jlayton@redhat.com>
