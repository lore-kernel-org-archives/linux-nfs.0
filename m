Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:42220 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261Ab0L3Joe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Dec 2010 04:44:34 -0500
Date: Thu, 30 Dec 2010 11:44:33 +0200
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Rob Landley <rlandley@parallels.com>
Cc: Rob Landley <rob@landley.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Message-ID: <20101230094433.GB29697@shutemov.name>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
 <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>
 <20101230085139.GA29697@shutemov.name>
 <4D1C4C7C.6050606@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D1C4C7C.6050606@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 30, 2010 at 03:10:20AM -0600, Rob Landley wrote:
> On 12/30/2010 02:51 AM, Kirill A. Shutemov wrote:
> > On Wed, Dec 29, 2010 at 08:13:50PM -0600, Rob Landley wrote:
> >> On Wed, Dec 29, 2010 at 7:14 AM, Kirill A. Shutemov<kas@openvz.org>  wrote:
> >>>
> >>> Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
> >>> Only for client for now.
> >>
> >> What would a test case for this look like?  (Is there some way to tell
> >> an nfs mount to use a specific instance of rpc_pipefs or something?)
> >
> > You can create a new instance of rpc_pipefs using 'newinstance'
> > mountoption.
> >
> > Then you can specify which rpc_pipefs to use with 'rpcmount' mountoption
> > of nfs mount. If none specifed, '/var/lib/nfs/rpc_pipefs' uses by default.
> 
> That path is as the process performing the mount sees it?

Yep.

> > If no rpcmount mountoption, no rpc_pipefs was found at
> > '/var/lib/nfs/rpc_pipefs' and we are in init's mount namespace, we use
> > init_rpc_pipefs.
> 
> It's the "we are in init's mount namespace" that I was wondering about.
> 
> So if I naievely chroot, nfs mount stops working the way it did before I 
> chrooted unless I do an extra setup step?

No. It will work as before since you are still in init's mount namespace.
Creating new mount namespace changes rules.

> I'm actually poking at getting nfs mount working in LXC containers with 
> different network routing (mostly study so far, it took me a couple 
> weeks just to get lxc to work for me and now I'm trying to wrap my head 
> around Linux's NFS implementation), so I'm very interested in this...

-- 
 Kirill A. Shutemov
