Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54038 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030329AbdIZNju (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Sep 2017 09:39:50 -0400
Date: Tue, 26 Sep 2017 09:39:49 -0400
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
Message-ID: <20170926133949.GB25286@fieldses.org>
References: <20170919151051.GS9536@redhat.com>
 <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
 <20170919172452.GB29104@fieldses.org>
 <20170921170017.GK32364@stefanha-x1.localdomain>
 <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com>
 <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com>
 <20170922115524.GN12725@redhat.com>
 <87efqu6wl4.fsf@notabene.neil.brown.name>
 <20170926034026.GA19283@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170926034026.GA19283@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 25, 2017 at 11:40:26PM -0400, J. Bruce Fields wrote:
> On Tue, Sep 26, 2017 at 12:08:07PM +1000, NeilBrown wrote:
> > Rather than a flag, it might work to use network namespaces.
> > Very early in the init sequence the filesystem gets mounted using the
> > IPv6 link-local address on a client->host interface, and then a new
> > network namespace is created which does not include that interface, and
> > which everything else including firewall code runs in.  Maybe.
> 
> That seems closer, since it allows you to hide the interface from most
> of the guest while letting some special software--qemu guest agent?--
> still work with it.  That agent would also need to be the one to do the
> mount, and would need to be able to make that mount usable to the rest
> of the guest.

On the other hand, you're not *really* hiding it--system software in the
guest can certainly find the interface if it wants to.  I don't know if
that's likely to cause any trouble in practice.

The same is true of VSOCK, I suppose.  But VSOCK being designed
specifically for host<->guest communications, anyone monkeying with it
knows what they're doing and is responsible for the consequences, in a
way which someone dealing with ordinary network interfaces and
namespaces isn't.

--b.
