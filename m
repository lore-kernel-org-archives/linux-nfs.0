Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60944 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750747AbdISJbq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Sep 2017 05:31:46 -0400
Date: Tue, 19 Sep 2017 10:31:40 +0100
From: "Daniel P. Berrange" <berrange@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170919093140.GF9536@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
 <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com>
 <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com>
 <20170914173730.GD4673@fieldses.org>
 <20170915131224.GC14994@stefanha-x1.localdomain>
 <20170915133145.GA23557@fieldses.org>
 <DE7FAAE5-26F5-4B11-A83D-F74C9B7D81FB@oracle.com>
 <20170915164223.GE23557@fieldses.org>
 <A1844833-18E1-4F03-BB20-A06A6FE4AB62@oracle.com>
 <20170918180927.GD12759@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20170918180927.GD12759@stefanha-x1.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 18, 2017 at 07:09:27PM +0100, Stefan Hajnoczi wrote:
> On Sat, Sep 16, 2017 at 08:55:21AM -0700, Chuck Lever wrote:
> > 
> > > On Sep 15, 2017, at 9:42 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > 
> > > On Fri, Sep 15, 2017 at 06:59:45AM -0700, Chuck Lever wrote:
> > >> 
> > >>> On Sep 15, 2017, at 6:31 AM, J . Bruce Fields <bfields@fieldses.org> wrote:
> > >>> 
> > >>> On Fri, Sep 15, 2017 at 02:12:24PM +0100, Stefan Hajnoczi wrote:
> > >>>> On Thu, Sep 14, 2017 at 01:37:30PM -0400, J . Bruce Fields wrote:
> > >>>>> On Thu, Sep 14, 2017 at 11:55:51AM -0400, Steve Dickson wrote:
> > >>>>>> On 09/14/2017 11:39 AM, Steve Dickson wrote:
> > >>>>>>> Hello
> > >>>>>>> 
> > >>>>>>> On 09/13/2017 06:26 AM, Stefan Hajnoczi wrote:
> > >>>>>>>> v3:
> > >>>>>>>> * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
> > >>>>>>>> * Added clientaddr autodetection in mount.nfs(8)
> > >>>>>>>> * Replaced #ifdefs with a single vsock.h header file
> > >>>>>>>> * Tested nfsd serving both IPv4 and vsock at the same time
> > >>>>>>> Just curious as to the status of the kernel patches... Are
> > >>>>>>> they slated for any particular release?
> > >>>>>> Maybe I should have read the thread before replying ;-) 
> > >>>>>> 
> > >>>>>> I now see the status of the patches... not good!  8-)
> > >>>>> 
> > >>>>> To be specific, the code itself is probably fine, it's just that nobody
> > >>>>> on the NFS side seems convinced that NFS/VSOCK is necessary.
> > >>>> 
> > >>>> Yes, the big question is whether the Linux NFS maintainers can see this
> > >>>> feature being merged.  It allows host<->guest file sharing in a way that
> > >>>> management tools can automate.
> > >>>> 
> > >>>> I have gotten feedback multiple times that NFS over TCP/IP is not an
> > >>>> option for management tools like libvirt to automate.
> > >>> 
> > >>> We're having trouble understanding why this is.
> > >> 
> > >> I'm also having trouble understanding why NFS is a better solution
> > >> in this case than a virtual disk, which does not require any net-
> > >> working to be configured. What exactly is expected to be shared
> > >> between the hypervisor and each guest?
> > > 
> > > They have said before there are uses for storage that's actually shared.
> > > (And I assume it would be mainly shared between guests rather than
> > > between guest and hypervisor?)
> > 
> > But this works today with IP-based networking. We certainly use
> > this kind of arrangement with OVM (Oracle's Xen-based hypervisor).
> > I agree NFS in the hypervisor is useful in interesting cases, but
> > I'm separating the need for a local NFS service with the need for
> > it to be zero-configuration.
> > 
> > The other use case that's been presented for NFS/VSOCK is an NFS
> > share that contains configuration information for each guest (in
> > particular, network configuration information). This is the case
> > I refer to above when I ask whether this can be done with a
> > virtual disk.
> > 
> > I don't see any need for concurrent access by the hypervisor and
> > guest, and one presumably should not share a guest's specific
> > configuration information with other guests. There would be no
> > sharing requirement, and therefore I would expect a virtual disk
> > filesystem would be adequate in this case and perhaps even
> > preferred, being more secure and less complex.
> 
> There are 2 main use cases:
> 
> 1. Easy file sharing between host & guest
> 
>    It's true that a disk image can be used but that's often inconvenient
>    when the data comes in individual files.  Making throwaway ISO or
>    disk image from those files requires extra disk space, is slow, etc.

More critically, it cannot be easily live-updated for a running guest.
Not all of the setup data that the hypervisor wants to share with the
guest is boot-time only - some may be access repeatedly post boot &
have a need to update it dynamically. Currently OpenStack can only
satisfy this if using its network based metadata REST service, but
many cloud operators refuse to deploy this because they are not happy
with the guest and host sharing a LAN, leaving only the virtual disk
option which can not support dynamic update.

If the admin takes any live snapshots of the guest, then this throwaway
disk image has to be kept around for the lifetime of the snapshot too.
We cannot just throw it away & re-generate it later when restoring the
snapshot, because we canot guarantee the newly generated image would be
byte-for-byte identical to the original one we generated due to possible
changes in mkfs related tools.

>    From a user perspective it's much nicer to point to a directory and
>    have it shared with the guest.
> 
> 2. Using NFS over AF_VSOCK as an interface for a distributed file system
>    like Ceph or Gluster.
> 
>    Hosting providers don't necessarily want to expose their distributed
>    file system directly to the guest.  An NFS frontend presents an NFS
>    file system to the guest.  The guest doesn't have access to the
>    distributed file system configuration details or network access.  The
>    hosting provider can even switch backend file systems without
>    requiring guest configuration changes.

Regards,
Daniel
-- 
|: https://berrange.com      -o-    https://www.flickr.com/photos/dberrange :|
|: https://libvirt.org         -o-            https://fstop138.berrange.com :|
|: https://entangle-photo.org    -o-    https://www.instagram.com/dberrange :|
