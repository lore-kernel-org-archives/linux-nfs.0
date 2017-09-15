Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43830 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751143AbdIOQp0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Sep 2017 12:45:26 -0400
Date: Fri, 15 Sep 2017 12:42:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170915164223.GE23557@fieldses.org>
References: <20170913102650.10377-1-stefanha@redhat.com>
 <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com>
 <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com>
 <20170914173730.GD4673@fieldses.org>
 <20170915131224.GC14994@stefanha-x1.localdomain>
 <20170915133145.GA23557@fieldses.org>
 <DE7FAAE5-26F5-4B11-A83D-F74C9B7D81FB@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <DE7FAAE5-26F5-4B11-A83D-F74C9B7D81FB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 15, 2017 at 06:59:45AM -0700, Chuck Lever wrote:
> 
> > On Sep 15, 2017, at 6:31 AM, J . Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Fri, Sep 15, 2017 at 02:12:24PM +0100, Stefan Hajnoczi wrote:
> >> On Thu, Sep 14, 2017 at 01:37:30PM -0400, J . Bruce Fields wrote:
> >>> On Thu, Sep 14, 2017 at 11:55:51AM -0400, Steve Dickson wrote:
> >>>> On 09/14/2017 11:39 AM, Steve Dickson wrote:
> >>>>> Hello
> >>>>> 
> >>>>> On 09/13/2017 06:26 AM, Stefan Hajnoczi wrote:
> >>>>>> v3:
> >>>>>> * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
> >>>>>> * Added clientaddr autodetection in mount.nfs(8)
> >>>>>> * Replaced #ifdefs with a single vsock.h header file
> >>>>>> * Tested nfsd serving both IPv4 and vsock at the same time
> >>>>> Just curious as to the status of the kernel patches... Are
> >>>>> they slated for any particular release?
> >>>> Maybe I should have read the thread before replying ;-) 
> >>>> 
> >>>> I now see the status of the patches... not good!  8-)
> >>> 
> >>> To be specific, the code itself is probably fine, it's just that nobody
> >>> on the NFS side seems convinced that NFS/VSOCK is necessary.
> >> 
> >> Yes, the big question is whether the Linux NFS maintainers can see this
> >> feature being merged.  It allows host<->guest file sharing in a way that
> >> management tools can automate.
> >> 
> >> I have gotten feedback multiple times that NFS over TCP/IP is not an
> >> option for management tools like libvirt to automate.
> > 
> > We're having trouble understanding why this is.
> 
> I'm also having trouble understanding why NFS is a better solution
> in this case than a virtual disk, which does not require any net-
> working to be configured. What exactly is expected to be shared
> between the hypervisor and each guest?

They have said before there are uses for storage that's actually shared.
(And I assume it would be mainly shared between guests rather than
between guest and hypervisor?)

> I do understand the use cases for a full-featured NFS server in
> the hypervisor, but not why it needs to be zero-config.

"It" in that question refers to the client, not the server, right?

--b.
