Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42610 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752762AbdI0NF2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Sep 2017 09:05:28 -0400
Date: Wed, 27 Sep 2017 14:05:23 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Daniel P. Berrange" <berrange@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170927130523.GD14579@stefanha-x1.localdomain>
References: <20170919164427.GV9536@redhat.com>
 <20170919172452.GB29104@fieldses.org>
 <20170921170017.GK32364@stefanha-x1.localdomain>
 <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com>
 <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com>
 <20170922115524.GN12725@redhat.com>
 <87efqu6wl4.fsf@notabene.neil.brown.name>
 <20170926034026.GA19283@fieldses.org>
 <20170926105626.GH16834@stefanha-x1.localdomain>
 <87bmlx6kbm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87bmlx6kbm.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 27, 2017 at 10:45:17AM +1000, NeilBrown wrote:
> On Tue, Sep 26 2017, Stefan Hajnoczi wrote:
> 
> > On Mon, Sep 25, 2017 at 11:40:26PM -0400, J. Bruce Fields wrote:
> >> On Tue, Sep 26, 2017 at 12:08:07PM +1000, NeilBrown wrote:
> >> > On Fri, Sep 22 2017, Daniel P. Berrange wrote:
> >> > Rather than a flag, it might work to use network namespaces.
> >> > Very early in the init sequence the filesystem gets mounted using the
> >> > IPv6 link-local address on a client->host interface, and then a new
> >> > network namespace is created which does not include that interface, and
> >> > which everything else including firewall code runs in.  Maybe.
> >> 
> >> That seems closer, since it allows you to hide the interface from most
> >> of the guest while letting some special software--qemu guest agent?--
> >> still work with it.  That agent would also need to be the one to do the
> >> mount, and would need to be able to make that mount usable to the rest
> >> of the guest.
> >> 
> >> Sounds doable to me?
> >> 
> >> There's still the problem of the paranoid security bureaucracy.
> >> 
> >> It should be pretty easy to demonstrate that the host only allows
> >> point-to-point traffic on these interfaces.  I'd hope that that, plus
> >> the appeal of the feature, would be enough to win out in the end.  This
> >> is not a class of problem that I have experience dealing with, though!
> >
> > Programs wishing to use host<->guest networking might still need the
> > main network namespace for UNIX domain sockets and other
> > communication.
> 
> Did I miss something.... the whole premise of this work seems to be that
> programs (nfs in particular) cannot rely on host<->guest networking
> because some rogue firewall might interfere with it, but now you say
> that some programs might rely on it....

Programs rely on IPC (e.g. UNIX domain sockets) and that's affected by
network namespace isolation.  This is what I was interested in.

But I've checked that UNIX domain socket connect(2) works across network
namespaces for pathname sockets.  The path to the socket file just needs
to be accessible via the file system.

> However I think you missed the important point - maybe I didn't explain
> it clearly.
> 
> My idea is that the "root" network namespace is only available in early
> boot.  An NFS mount happens then (and possibly a daemon hangs around in
> this network namespace to refresh the NFS mount).  A new network
> namespace is created and *everthing*else* runs in that subordinate
> namespace.
> 
> If you want host<->guest networking in this subordinate namespace you
> are quite welcome to configure that - maybe a vethX interface which
> bridges out to the host interface.
> But the important point is that any iptables rules configured in the
> subordinate namespace will not affect the primary namespace and so will
> not hurt the NFS mount. They will be entirely local.

Using the "root" (initial) network namespace is invasive.  Hotplugged
NICs appear in the initial network netspace and interfaces move there if
a subordinate namespace is destroyed.  Were you thinking of this
approach because it could share a single NIC (you mentioned bridging)?

Maybe it's best to leave the initial network namespace alone and instead
create a host<->guest namespace with a dedicated virtio-net NIC.  That
way hotplug and network management continues to work as usual except
there is another namespace that contains a dedicated virtio-net NIC for
NFS and other host<->guest activity.

> There should be no need to move between namespaces once they have been
> set up.

If the namespace approach is better than AF_VSOCK, then it should work
for more use cases than just NFS.  The QEMU Guest Agent was mentioned,
for example.

The guest agent needs to see the guest's network interfaces so it can
report the guest IP address.  Therefore it needs access to both network
namespaces and I wondered what the cleanest way to do that was.

Stefan
