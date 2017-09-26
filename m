Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54520 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031149AbdIZScF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Sep 2017 14:32:05 -0400
Date: Tue, 26 Sep 2017 14:32:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: NeilBrown <neilb@suse.com>,
        "Daniel P. Berrange" <berrange@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170926183205.GA28914@fieldses.org>
References: <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
 <20170919172452.GB29104@fieldses.org>
 <20170921170017.GK32364@stefanha-x1.localdomain>
 <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com>
 <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com>
 <20170922115524.GN12725@redhat.com>
 <87efqu6wl4.fsf@notabene.neil.brown.name>
 <20170926034026.GA19283@fieldses.org>
 <20170926105626.GH16834@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170926105626.GH16834@stefanha-x1.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 26, 2017 at 11:56:26AM +0100, Stefan Hajnoczi wrote:
> On Mon, Sep 25, 2017 at 11:40:26PM -0400, J. Bruce Fields wrote:
> > On Tue, Sep 26, 2017 at 12:08:07PM +1000, NeilBrown wrote:
> > > On Fri, Sep 22 2017, Daniel P. Berrange wrote:
> > > Rather than a flag, it might work to use network namespaces.
> > > Very early in the init sequence the filesystem gets mounted using the
> > > IPv6 link-local address on a client->host interface, and then a new
> > > network namespace is created which does not include that interface, and
> > > which everything else including firewall code runs in.  Maybe.
> > 
> > That seems closer, since it allows you to hide the interface from most
> > of the guest while letting some special software--qemu guest agent?--
> > still work with it.  That agent would also need to be the one to do the
> > mount, and would need to be able to make that mount usable to the rest
> > of the guest.
> > 
> > Sounds doable to me?
> > 
> > There's still the problem of the paranoid security bureaucracy.
> > 
> > It should be pretty easy to demonstrate that the host only allows
> > point-to-point traffic on these interfaces.  I'd hope that that, plus
> > the appeal of the feature, would be enough to win out in the end.  This
> > is not a class of problem that I have experience dealing with, though!
> 
> Programs wishing to use host<->guest networking might still need the
> main network namespace for UNIX domain sockets and other communication.
> 
> For example, the QEMU guest agent has a command to report the IP
> addresses of the guest.  It must access the main network namespace to
> collect this information while using a host<->guest socket to
> communicate with the hypervisor.
> 
> I think this can be achieved as follows:
> 1. open /proc/self/ns/net (stash the file descriptor)
> 2. open /var/run/netns/hvnet & call setns(2) to switch namespaces
> 3. socket(AF_INET6, SOCK_STREAM, 0) to create host<->guest socket
> 4. call setns(2) to switch back to main namespace
> 
> In other words, the program stays mostly in the main network namespace
> and only enters the host<->guest namespace to create sockets.

Sounds like it would work.  Or use two communicating processes, one in
each namespace?

> setns(2) with a network namespace requires CAP_SYS_ADMIN so it's not
> very practical.

The guest agent will need root to do NFS mounts.

> Is there an alternative that makes using the host<->guest network
> namespace less clunky?

You'll have to define "clunky" for us....

--b.
