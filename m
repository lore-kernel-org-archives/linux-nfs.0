Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43540 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751303AbdIONbp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Sep 2017 09:31:45 -0400
Date: Fri, 15 Sep 2017 09:31:45 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Steve Dickson <SteveD@RedHat.com>, linux-nfs@vger.kernel.org,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170915133145.GA23557@fieldses.org>
References: <20170913102650.10377-1-stefanha@redhat.com>
 <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com>
 <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com>
 <20170914173730.GD4673@fieldses.org>
 <20170915131224.GC14994@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170915131224.GC14994@stefanha-x1.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 15, 2017 at 02:12:24PM +0100, Stefan Hajnoczi wrote:
> On Thu, Sep 14, 2017 at 01:37:30PM -0400, J . Bruce Fields wrote:
> > On Thu, Sep 14, 2017 at 11:55:51AM -0400, Steve Dickson wrote:
> > > On 09/14/2017 11:39 AM, Steve Dickson wrote:
> > > > Hello
> > > > 
> > > > On 09/13/2017 06:26 AM, Stefan Hajnoczi wrote:
> > > >> v3:
> > > >>  * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
> > > >>  * Added clientaddr autodetection in mount.nfs(8)
> > > >>  * Replaced #ifdefs with a single vsock.h header file
> > > >>  * Tested nfsd serving both IPv4 and vsock at the same time
> > > > Just curious as to the status of the kernel patches... Are
> > > > they slated for any particular release?
> > > Maybe I should have read the thread before replying ;-) 
> > > 
> > > I now see the status of the patches... not good!  8-)
> > 
> > To be specific, the code itself is probably fine, it's just that nobody
> > on the NFS side seems convinced that NFS/VSOCK is necessary.
> 
> Yes, the big question is whether the Linux NFS maintainers can see this
> feature being merged.  It allows host<->guest file sharing in a way that
> management tools can automate.
> 
> I have gotten feedback multiple times that NFS over TCP/IP is not an
> option for management tools like libvirt to automate.

We're having trouble understanding why this is.

Maybe it would help if you could put us directly in touch with the
sources of those feedback?

--b.

> They want
> something that is both zero-configuration and not prone to breakage
> inside the guest.  AF_VSOCK has those qualities.
> 
> Can you give a verdict on NFS over AF_VSOCK as Linux NFS maintainers?
> 
> If the verdict is yes, then I'll submit the kernel patch series and get
> to work on netid registration.  If no, then everyone can move on and
> I'll figure out what to do next.
> 
> The latest kernel code is here:
> https://github.com/stefanha/linux/tree/vsock-nfsd
> 
> Stefan
> 
> PS: I removed Neil Brown from CC because he requested not to be included
> on this patch series.
