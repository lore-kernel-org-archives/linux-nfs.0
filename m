Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43700 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751152AbdIOPR4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Sep 2017 11:17:56 -0400
Date: Fri, 15 Sep 2017 11:17:55 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org,
        NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@RedHat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170915151755.GD23557@fieldses.org>
References: <20170913102650.10377-1-stefanha@redhat.com>
 <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com>
 <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com>
 <20170914173730.GD4673@fieldses.org>
 <1505473626.4781.9.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1505473626.4781.9.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 15, 2017 at 07:07:06AM -0400, Jeff Layton wrote:
> On Thu, 2017-09-14 at 13:37 -0400, J . Bruce Fields wrote:
> > On Thu, Sep 14, 2017 at 11:55:51AM -0400, Steve Dickson wrote:
> > > 
> > > 
> > > On 09/14/2017 11:39 AM, Steve Dickson wrote:
> > > > Hello
> > > > 
> > > > On 09/13/2017 06:26 AM, Stefan Hajnoczi wrote:
> > > > > v3:
> > > > >  * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
> > > > >  * Added clientaddr autodetection in mount.nfs(8)
> > > > >  * Replaced #ifdefs with a single vsock.h header file
> > > > >  * Tested nfsd serving both IPv4 and vsock at the same time
> > > > 
> > > > Just curious as to the status of the kernel patches... Are
> > > > they slated for any particular release?
> > > 
> > > Maybe I should have read the thread before replying ;-) 
> > > 
> > > I now see the status of the patches... not good!  8-)
> > 
> > To be specific, the code itself is probably fine, it's just that nobody
> > on the NFS side seems convinced that NFS/VSOCK is necessary.
> > 
> 
> ...and to be even more clear, the problem you've outlined (having a zero
> config network between an HV and guest) is a valid one. The issue here
> is that the solution in these patches is horribly invasive and will
> create an ongoing maintenance burden.
> 
> What would be much cleaner (IMNSHO) is a new type of virtual network
> interface driver that has similar communication characteristics (only
> allowing HV<->guest communication) and that autoconfigures itself when
> plugged in (or only does so with minimal setup).
> 
> Then you could achieve the same result without having to completely
> rework all of this code. That's also something potentially backportable
> to earlier kernels, which is a nice bonus.

We're talking about NFS/VSOCK here, but everything you've said would
apply to any protocol over VSOCK.

And yet, we have VSOCK.  So I still feel like we must be missing
some perspective.

I wonder if part of the problem is that we're imagining that the typical
VM has a sysadmin.  Isn't it more likely that you build the VM
automatically from some root image that you don't even maintain
yourself?  So fixing it to not, say, block all network traffic on every
interface, isn't something you can automate--you've no idea where the
iptables configuration lives in the image.

--b.
