Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:54103 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752890Ab0L3KoR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Dec 2010 05:44:17 -0500
Date: Thu, 30 Dec 2010 12:44:16 +0200
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Rob Landley <rlandley@parallels.com>
Cc: "Kirill A. Shutemov" <kas@openvz.org>, Rob Landley <rob@landley.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Message-ID: <20101230104416.GA31824@shutemov.name>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
 <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>
 <20101230085139.GA29697@shutemov.name>
 <4D1C4C7C.6050606@parallels.com>
 <20101230094433.GB29697@shutemov.name>
 <4D1C5953.6020200@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D1C5953.6020200@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 30, 2010 at 04:05:07AM -0600, Rob Landley wrote:
> On 12/30/2010 03:44 AM, Kirill A. Shutemov wrote:
> >>> If no rpcmount mountoption, no rpc_pipefs was found at
> >>> '/var/lib/nfs/rpc_pipefs' and we are in init's mount namespace, we use
> >>> init_rpc_pipefs.
> >>
> >> It's the "we are in init's mount namespace" that I was wondering about.
> >>
> >> So if I naievely chroot, nfs mount stops working the way it did before I
> >> chrooted unless I do an extra setup step?
> >
> > No. It will work as before since you are still in init's mount namespace.
> > Creating new mount namespace changes rules.
> 
> Ah, CLONE_NEWNS and then you need /var/lib/nfs/rpc_pipefs.  Got it.
> 
> I'm kind of surprised that the kernel cares about a specific path under 
> /var/lib.  (Seems like policy in the kernel somehow.)

Yep. It's bad, but there is way to overwrite the default.

Other way is to leave 'rpcmount' mountoption without default.
get_rpc_pipefs(NULL) in init's mount namespace will always return
init_rpc_pipefs, without filesystem lookup.
get_rpc_pipefs(NULL) in non-init's mount namespace will always return
error.

So you will have to specify 'rpcmount' mountoption for every nfs mount in
container. Hmm, I guess, it may confuse user.

Or we can try to move the default to userspace. /sbin/mount.nfs?

> Can't it just 
> check the current process's mount list to see if an instance of 
> rpc_pipefs is mounted in the current namespace the way lxc looks for 
> cgroups?  Or are there potential performance/scalability issues with that?

What should we do if we have several rpc_pipefs mounts in the namespace?

-- 
 Kirill A. Shutemov
