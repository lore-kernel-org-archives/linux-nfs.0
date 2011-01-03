Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:46499 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285Ab1ACUs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 15:48:58 -0500
Message-ID: <4D22362F.2040604@parallels.com>
Date: Mon, 3 Jan 2011 14:48:47 -0600
From: Rob Landley <rlandley@parallels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "Kirill A. Shutemov" <kas@openvz.org>, Rob Landley <rob@landley.net>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, <linux-nfs@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
References: <1293628470-28386-1-git-send-email-kas@openvz.org>	 <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>	 <20101230085139.GA29697@shutemov.name> <4D1C4C7C.6050606@parallels.com>	 <20101230094433.GB29697@shutemov.name>  <4D1C5953.6020200@parallels.com> <1293814441.2980.4.camel@heimdal.trondhjem.org>
In-Reply-To: <1293814441.2980.4.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 12/31/2010 10:54 AM, Trond Myklebust wrote:
>> I'm kind of surprised that the kernel cares about a specific path under
>> /var/lib.  (Seems like policy in the kernel somehow.)  Can't it just
>> check the current process's mount list to see if an instance of
>> rpc_pipefs is mounted in the current namespace the way lxc looks for
>> cgroups?  Or are there potential performance/scalability issues with that?
>
> The kernel doesn't give a damn about the /var/lib/nfs/rpc_pipefs bit.
> That's all for the benefit of the userland utilities.

Are you saying that if you go into a container and that mount point 
doesn't exist, the kernel will still be able to find and use rpc_pipefs? 
  Without userspace creating a specific magic path and mounting a 
filesystem on it?

If so, I misread the patch...

Rob

