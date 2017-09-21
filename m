Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33076 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751792AbdIVIcF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Sep 2017 04:32:05 -0400
Date: Thu, 21 Sep 2017 18:00:17 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Daniel P. Berrange" <berrange@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170921170017.GK32364@stefanha-x1.localdomain>
References: <DE7FAAE5-26F5-4B11-A83D-F74C9B7D81FB@oracle.com>
 <20170915164223.GE23557@fieldses.org>
 <A1844833-18E1-4F03-BB20-A06A6FE4AB62@oracle.com>
 <20170918180927.GD12759@stefanha-x1.localdomain>
 <20170919093140.GF9536@redhat.com>
 <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com>
 <20170919151051.GS9536@redhat.com>
 <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
 <20170919172452.GB29104@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170919172452.GB29104@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 19, 2017 at 01:24:52PM -0400, J. Bruce Fields wrote:
> On Tue, Sep 19, 2017 at 05:44:27PM +0100, Daniel P. Berrange wrote:
> > On Tue, Sep 19, 2017 at 11:48:10AM -0400, Chuck Lever wrote:
> > > 
> > > > On Sep 19, 2017, at 11:10 AM, Daniel P. Berrange <berrange@redhat.com> wrote:
> > > > VSOCK requires no guest configuration, it won't be broken accidentally
> > > > by NetworkManager (or equivalent), it won't be mistakenly blocked by
> > > > guest admin/OS adding "deny all" default firewall policy. Similar
> > > > applies on the host side, and since there's separation from IP networking,
> > > > there is no possibility of the guest ever getting a channel out to the
> > > > LAN, even if the host is mis-configurated.
> > > 
> > > We don't seem to have configuration fragility problems with other
> > > deployments that scale horizontally.
> > > 
> > > IMO you should focus on making IP reliable rather than trying to
> > > move familiar IP-based services to other network fabrics.
> > 
> > I don't see that ever happening, except in a scenario where a single
> > org is in tight control of the whole stack (host & guest), which is
> > not the case for cloud in general - only some on-site clouds.
> 
> Can you elaborate?
> 
> I think we're having trouble understanding why you can't just say "don't
> do that" to someone whose guest configuration is interfering with the
> network interface they need for NFS.

Dan can add more information on the OpenStack use case, but your
question is equally relevant to the other use case I mentioned - easy
file sharing between host and guest.

Management tools like virt-manager (https://virt-manager.org/) should
support a "share directory with VM" feature.  The user chooses a
directory on the host, a mount point inside the guest, and then clicks
OK.  The directory should appear inside the guest.

VMware, VirtualBox, etc have had file sharing for a long time.  It's a
standard feature.

Here is how to implement it using AF_VSOCK:
1. Check presence of virtio-vsock device in VM or hotplug it.
2. Export directory from host NFS server (nfs-ganesha, nfsd, etc).
3. Send qemu-guest-agent command to (optionally) add /etc/fstab entry
   and then mount.

The user does not need to take any action inside the guest.
Non-technical users can share files without even knowing what NFS is.

There are too many scenarios where guest administrator action is
required with NFS over TCP/IP.  We can't tell them "don't do that"
because it makes this feature unreliable.

Today we ask users to set up NFS or CIFS themselves.  In many cases that
is inconvenient and an easy file sharing feature would be much better.

Stefan
