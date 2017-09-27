Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56156 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752734AbdI0Nqe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Sep 2017 09:46:34 -0400
Date: Wed, 27 Sep 2017 09:46:34 -0400
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
Message-ID: <20170927134634.GB9585@fieldses.org>
References: <20170919172452.GB29104@fieldses.org>
 <20170921170017.GK32364@stefanha-x1.localdomain>
 <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com>
 <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com>
 <20170922115524.GN12725@redhat.com>
 <87efqu6wl4.fsf@notabene.neil.brown.name>
 <20170926034026.GA19283@fieldses.org>
 <20170926133949.GB25286@fieldses.org>
 <20170926134239.GC25286@fieldses.org>
 <20170927122258.GC14579@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170927122258.GC14579@stefanha-x1.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 27, 2017 at 01:22:58PM +0100, Stefan Hajnoczi wrote:
> On Tue, Sep 26, 2017 at 09:42:39AM -0400, J. Bruce Fields wrote:
> > By the way, do we know anything about likely performance of NFS/VSOCK?
> 
> virtio-vsock is designed for reliable host<->guest communication, not
> performance.  It is not a fast-path to avoid Ethernet/IP.  I haven't run
> benchmarks on NFS over AF_VSOCK but don't expect its performance to set
> it apart from virtio-net.

OK.

But if we implement NFS/VSOCK and it turns out to be a success, I expect
people will start using it for things that weren't expected and
complaining about performance issues.

I guess I'm not too concerned about performance of the initial
implementation but it'd be nice to know that there's the possibility to
optimize later on.

But if our answer will be just to go figure out how to use a proper
NFS/TCP mount instead then I suppose that's OK.

--b.
