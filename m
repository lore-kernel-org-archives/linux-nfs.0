Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48346 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933294AbdIYIa2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Sep 2017 04:30:28 -0400
Date: Mon, 25 Sep 2017 09:30:20 +0100
From: "Daniel P. Berrange" <berrange@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170925083020.GB17374@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange@redhat.com>
References: <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com>
 <20170919151051.GS9536@redhat.com>
 <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
 <20170919172452.GB29104@fieldses.org>
 <20170921170017.GK32364@stefanha-x1.localdomain>
 <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com>
 <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com>
 <20170922115524.GN12725@redhat.com>
 <20170922191457.GA4786@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20170922191457.GA4786@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 22, 2017 at 03:14:57PM -0400, J. Bruce Fields wrote:
> On Fri, Sep 22, 2017 at 12:55:24PM +0100, Daniel P. Berrange wrote:
> > On Fri, Sep 22, 2017 at 07:43:39AM -0400, Chuck Lever wrote:
> > > If firewall configuration is a chronic problem, let's address that.
> > 
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
> I guess what's confusing to me is you're already depending on a ton of
> assumptions about the guest:
> 
> 	- it has to be running a recent kernel with NFS/VSOCK support.
> 	- it has to have all the nfs-utils userspace stuff, a
> 	  /usr/bin/mount that works the way you expect, and an
> 	  /etc/nfsmount.conf that doesn't have any odd options.
> 	- it has to have a suitable mount point somewhere that the admin
> 	  knows about.
> 	- probably lots of other stuff
> 
> It's odd that the firewall configuration is the one step too far.

The key factor is considering which pieces are liable to significant or
complex interactions with other usage of the OS, and are thus liable to
be accidentally misconfigured or at risk of breaking during usage. The
configuration of network interfaces and firewalls is very major risk
area compared to the other pre-requisites.

Providing a kernel/userspace with the feature is taken care of by the
distro vendor and OS admins can't break this unless they go out of their
way to prevent loading of the kernel modules which is not a likely
scenario.  Making a mount point is straightforward and not something
that other services in the system are liable to break. Potentially the
mount point creation can be either baked into the guest OS pre-built
disk image, or populated by metadata from another source. The nfsmount.conf
options are a possible source of concern, but IIUC, anything set there is
possible to override via explicit args to mount.

The way in which network interfaces are configured though is a major
source of complexity & unknowns because it is not something the distro
vendor just defines once. There are countless different tools to
configure network interfaces on Linux alone, and many permutations of
how the actual interfaces / routing are setup. Firewall setup is a
similar place of complexity & unknowns, because not only are there many
different tools to manage it, but you get well into the realm of policy
defined by the organizations deploying it. Expecting things to "just work"
in this area is just unrealistic. It is a big part of why virtualization
platforms all provide dedicated paravirtualized devices for communication
between host and guest, that is independant of networking.

Regards,
Daniel
-- 
|: https://berrange.com      -o-    https://www.flickr.com/photos/dberrange :|
|: https://libvirt.org         -o-            https://fstop138.berrange.com :|
|: https://entangle-photo.org    -o-    https://www.instagram.com/dberrange :|
