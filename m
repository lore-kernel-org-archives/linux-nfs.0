Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45556 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751249AbdIPOz6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 16 Sep 2017 10:55:58 -0400
Date: Sat, 16 Sep 2017 10:55:58 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        linux-nfs@vger.kernel.org, Matt Benjamin <mbenjami@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@RedHat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170916145558.GB3866@fieldses.org>
References: <20170913102650.10377-1-stefanha@redhat.com>
 <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com>
 <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com>
 <20170914173730.GD4673@fieldses.org>
 <1505473626.4781.9.camel@redhat.com>
 <20170915151755.GD23557@fieldses.org>
 <874ls38rrx.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <874ls38rrx.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 16, 2017 at 09:29:38AM +1000, NeilBrown wrote:
> On Fri, Sep 15 2017, J . Bruce Fields wrote:
> 
> > On Fri, Sep 15, 2017 at 07:07:06AM -0400, Jeff Layton wrote:
> >> On Thu, 2017-09-14 at 13:37 -0400, J . Bruce Fields wrote:
> >> > On Thu, Sep 14, 2017 at 11:55:51AM -0400, Steve Dickson wrote:
> >> > > 
> >> > > 
> >> > > On 09/14/2017 11:39 AM, Steve Dickson wrote:
> >> > > > Hello
> >> > > > 
> >> > > > On 09/13/2017 06:26 AM, Stefan Hajnoczi wrote:
> >> > > > > v3:
> >> > > > >  * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
> >> > > > >  * Added clientaddr autodetection in mount.nfs(8)
> >> > > > >  * Replaced #ifdefs with a single vsock.h header file
> >> > > > >  * Tested nfsd serving both IPv4 and vsock at the same time
> >> > > > 
> >> > > > Just curious as to the status of the kernel patches... Are
> >> > > > they slated for any particular release?
> >> > > 
> >> > > Maybe I should have read the thread before replying ;-) 
> >> > > 
> >> > > I now see the status of the patches... not good!  8-)
> >> > 
> >> > To be specific, the code itself is probably fine, it's just that nobody
> >> > on the NFS side seems convinced that NFS/VSOCK is necessary.
> >> > 
> >> 
> >> ...and to be even more clear, the problem you've outlined (having a zero
> >> config network between an HV and guest) is a valid one. The issue here
> >> is that the solution in these patches is horribly invasive and will
> >> create an ongoing maintenance burden.
> >> 
> >> What would be much cleaner (IMNSHO) is a new type of virtual network
> >> interface driver that has similar communication characteristics (only
> >> allowing HV<->guest communication) and that autoconfigures itself when
> >> plugged in (or only does so with minimal setup).
> >> 
> >> Then you could achieve the same result without having to completely
> >> rework all of this code. That's also something potentially backportable
> >> to earlier kernels, which is a nice bonus.
> >
> > We're talking about NFS/VSOCK here, but everything you've said would
> > apply to any protocol over VSOCK.
> >
> > And yet, we have VSOCK.  So I still feel like we must be missing
> > some perspective.
> 
> Being in the kernel doesn't prove much.  devfs was in the kernel, so was
> the tux http service.  configfs is still in the kernel ! :-)
> 
> Possibly some perspective is missing.  A charitable reading of the
> situation is that the proponents of VSOCK aren't very good at
> communicating their requirements and vision.  A less charitable
> interpretation is that they have too much invested in VSOCK to be able
> to conceive an alternative.
> 
> The thing we hear about is "zero-conf" and that is obviously a good
> idea, but can be done without VSOCK.  What we hear less about is
> "fool-proof" which is hard to define and hard to sell, yet it seems to
> be an important part of their agenda.
> 
> >
> > I wonder if part of the problem is that we're imagining that the typical
> > VM has a sysadmin.  Isn't it more likely that you build the VM
> > automatically from some root image that you don't even maintain
> > yourself?  So fixing it to not, say, block all network traffic on every
> > interface, isn't something you can automate--you've no idea where the
> > iptables configuration lives in the image.
> 
> You are describing a situation where someone builds an important part of
> their infrastructure from something they don't understand and cannot
> maintain.

That describes applications pretty well from the point of view of most
users?

And I thought applications were increasingly get packaged with their
OS's.  I don't know, I haven't been following this stuff so I'm just
speculating.

> Obviously that happens, but when it does I would expect there
> to be someone who does understand.  A vendor or support organization
> probably.  If the end result doesn't fit the customer's needs, then that
> creates a market opportunity for someone to fill.

So that means getting those vendos to all agree to leave NFS traffic, or
particular classes of network interfaces, or something, unfiltered?

> It does seem that the unpredictability of network filtering is part of
> the goal of VSOCK, though creating a new network path that cannot be
> filtered doesn't seem to me like the cleverest idea in the long term.
> There seems to be more though.  There was a suggestion that some people
> don't want any network interface at all (but still want to use a
> networked file system).  This sounds like superstition, but was not
> backed up with data so I cannot be sure.
> 
> It does seem justifiable to want a simple and reliable way to ensure
> that traffic from the NFS client to the host is not filtered.  My
> feeling is that talking to network/firewall people is the best way to
> achieve that.  The approach that has been taken looks like an end-run
> around exactly the people who are in the best position to help.
> 
> How do network namespaces work?  Does each namespace get separate
> iptables?  Could we perform an NFS mount in an unfiltered namespace,
> then make everything else run with filters in place?

I don't know.  I'm hoping we can figure out who's closest to the source
of these requirements and sit down with some of the ideas and have them
explain to us whether they work or if not, why not.

--b.
