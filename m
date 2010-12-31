Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55749 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752936Ab0LaQyW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Dec 2010 11:54:22 -0500
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Rob Landley <rlandley@parallels.com>
Cc: "Kirill A. Shutemov" <kas@openvz.org>, Rob Landley <rob@landley.net>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
In-Reply-To: <4D1C5953.6020200@parallels.com>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
	 <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>
	 <20101230085139.GA29697@shutemov.name> <4D1C4C7C.6050606@parallels.com>
	 <20101230094433.GB29697@shutemov.name>  <4D1C5953.6020200@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 31 Dec 2010 11:54:01 -0500
Message-ID: <1293814441.2980.4.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-30 at 04:05 -0600, Rob Landley wrote: 
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
> /var/lib.  (Seems like policy in the kernel somehow.)  Can't it just 
> check the current process's mount list to see if an instance of 
> rpc_pipefs is mounted in the current namespace the way lxc looks for 
> cgroups?  Or are there potential performance/scalability issues with that?

The kernel doesn't give a damn about the /var/lib/nfs/rpc_pipefs bit.
That's all for the benefit of the userland utilities.

  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

