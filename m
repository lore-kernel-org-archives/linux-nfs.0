Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53074 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933685AbdIZDk1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Sep 2017 23:40:27 -0400
Date: Mon, 25 Sep 2017 23:40:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: "Daniel P. Berrange" <berrange@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170926034026.GA19283@fieldses.org>
References: <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com>
 <20170919151051.GS9536@redhat.com>
 <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
 <20170919172452.GB29104@fieldses.org>
 <20170921170017.GK32364@stefanha-x1.localdomain>
 <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com>
 <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com>
 <20170922115524.GN12725@redhat.com>
 <87efqu6wl4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87efqu6wl4.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 26, 2017 at 12:08:07PM +1000, NeilBrown wrote:
> On Fri, Sep 22 2017, Daniel P. Berrange wrote:
> > This just isn't practical in the general case. Even on a single Linux OS
> > distro there are multiple ways to manage firewalls (Fedora as a static
> > init script, or firewalld, and many users invent their own personal way
> > of doing it). There are countless other OS, many closed source with 3rd
> > party firewall products in use. And then there are the firewall policies
> > defined by organization's IT departments that mandate particular ways of
> > doing things with layers of approval to go through to get changes made.
> >
> > IOW, while improving firewall configuraiton is a worthy goal, it isn't
> > a substitute for host<->guest file system sharing over a non-network
> > based transport. 
> 
> I don't find this argument at all convincing.
> 
> The main selling point for VSOCK seems to be that it bypassed all
> firewalls.  i.e. traffic through a VSOCK is immune to any netfilter
> settings.
> 
> If "traffic immune to any netfilter settings" is a useful thing (and I'm
> quite willing to believe that it is), then let's focus on that goal.  It
> might be useful well beyond NFS and VMs.
> 
> How about a flag for a network interface which says "disable netfilter"??

Sounds like network configuration tools in general are a problem, so
it'd probably need to disable more than just netfilter.

But if iptable configuration and other operations start failing or
behaving strangely on one special interface, I'd worry that stuff will
break.

So I think you'd really want the interface completely hidden.

Except that you still want to configure the interface yourself using the
usual interfaces.  So:

> Rather than a flag, it might work to use network namespaces.
> Very early in the init sequence the filesystem gets mounted using the
> IPv6 link-local address on a client->host interface, and then a new
> network namespace is created which does not include that interface, and
> which everything else including firewall code runs in.  Maybe.

That seems closer, since it allows you to hide the interface from most
of the guest while letting some special software--qemu guest agent?--
still work with it.  That agent would also need to be the one to do the
mount, and would need to be able to make that mount usable to the rest
of the guest.

Sounds doable to me?

There's still the problem of the paranoid security bureaucracy.

It should be pretty easy to demonstrate that the host only allows
point-to-point traffic on these interfaces.  I'd hope that that, plus
the appeal of the feature, would be enough to win out in the end.  This
is not a class of problem that I have experience dealing with, though!

--b.
