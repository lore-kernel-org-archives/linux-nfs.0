Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:58651 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291Ab0L3LpP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Dec 2010 06:45:15 -0500
Date: Thu, 30 Dec 2010 13:45:14 +0200
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Rob Landley <rob@landley.net>
Cc: "Kirill A. Shutemov" <kas@openvz.org>,
        Rob Landley <rlandley@parallels.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Message-ID: <20101230114514.GA31976@shutemov.name>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
 <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>
 <20101230085139.GA29697@shutemov.name>
 <4D1C4C7C.6050606@parallels.com>
 <20101230094433.GB29697@shutemov.name>
 <4D1C5953.6020200@parallels.com>
 <20101230104416.GA31824@shutemov.name>
 <AANLkTim2QrkSW0HufD5wp=-8ikwydN5SUS+fdWK6JHqb@mail.gmail.com>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <AANLkTim2QrkSW0HufD5wp=-8ikwydN5SUS+fdWK6JHqb@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 30, 2010 at 05:05:22AM -0600, Rob Landley wrote:
> On Thu, Dec 30, 2010 at 4:44 AM, Kirill A. Shutemov <kas@openvz.org> wrote:
> > On Thu, Dec 30, 2010 at 04:05:07AM -0600, Rob Landley wrote:
> >> On 12/30/2010 03:44 AM, Kirill A. Shutemov wrote:
> >> >>> If no rpcmount mountoption, no rpc_pipefs was found at
> >> >>> '/var/lib/nfs/rpc_pipefs' and we are in init's mount namespace, we use
> >> >>> init_rpc_pipefs.
> >> >>
> >> >> It's the "we are in init's mount namespace" that I was wondering about.
> >> >>
> >> >> So if I naievely chroot, nfs mount stops working the way it did before I
> >> >> chrooted unless I do an extra setup step?
> >> >
> >> > No. It will work as before since you are still in init's mount namespace.
> >> > Creating new mount namespace changes rules.
> >>
> >> Ah, CLONE_NEWNS and then you need /var/lib/nfs/rpc_pipefs.  Got it.
> >>
> >> I'm kind of surprised that the kernel cares about a specific path under
> >> /var/lib.  (Seems like policy in the kernel somehow.)
> >
> > Yep. It's bad, but there is way to overwrite the default.
> >
> > Other way is to leave 'rpcmount' mountoption without default.
> > get_rpc_pipefs(NULL) in init's mount namespace will always return
> > init_rpc_pipefs, without filesystem lookup.
> > get_rpc_pipefs(NULL) in non-init's mount namespace will always return
> > error.
> >
> > So you will have to specify 'rpcmount' mountoption for every nfs mount in
> > container. Hmm, I guess, it may confuse user.
> >
> > Or we can try to move the default to userspace. /sbin/mount.nfs?
> 
> /proc/sys/kernel/hotplug exists to tell the kernel where to find the hotplug
> binary.  Once upon a time /sys/hotplug was the default value, and that was
> there to overwrite it.  (They changed the default to blank (disabled) not due
> to policy reasons, but due to adding the netlink hotplug notification
> mechanism and making that the default.)
> 
> I bring that up to point out that the general consensus about policy in the
> kernel seems to be "when you really really can't avoid having any, make a
> sane default the user can override".
> 
> (Of course adding another entry to the crawling horror of /proc may not
> be an improvement.  But individual overrides at the mount -o level seem
> like a non-optimal granularity for this...)

Do you propose to implement default as sysctl parameter?

> >> Can't it just
> >> check the current process's mount list to see if an instance of
> >> rpc_pipefs is mounted in the current namespace the way lxc looks for
> >> cgroups?  Or are there potential performance/scalability issues with that?
> >
> > What should we do if we have several rpc_pipefs mounts in the namespace?
> 
> You mean more than one inside a given process's view of the filesystem, taking
> into account chroot like /proc/mounts does?
> 
> Before this patch series, there was one instance systemwide.  The patch changed
> that to look a fixed location in the filesystem relative to the
> current chroot.  Either
> way, there was one instance available to a given process doing an nfs mount.
> 
> What's the use case for having more than one visible to a given process?
> (NUMA scalability?  Some sort of multipath/VPN routing context?)

It's no so obvious for me why we should restrict it. ;)

Currently, there is no association between rpc_pipefs and mount namespace,
so I don't see simple way to restrict number of rpc_pipefs per mount
namespace. Associating mount namespace with rpc_pipefs is not a good idea,
I think.

-- 
 Kirill A. Shutemov
