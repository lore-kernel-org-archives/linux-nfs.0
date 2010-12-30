Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:49440 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753152Ab0L3KFL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Dec 2010 05:05:11 -0500
Message-ID: <4D1C5953.6020200@parallels.com>
Date: Thu, 30 Dec 2010 04:05:07 -0600
From: Rob Landley <rlandley@parallels.com>
To: "Kirill A. Shutemov" <kas@openvz.org>
CC: Rob Landley <rob@landley.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, <linux-nfs@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
References: <1293628470-28386-1-git-send-email-kas@openvz.org> <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com> <20101230085139.GA29697@shutemov.name> <4D1C4C7C.6050606@parallels.com> <20101230094433.GB29697@shutemov.name>
In-Reply-To: <20101230094433.GB29697@shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 12/30/2010 03:44 AM, Kirill A. Shutemov wrote:
>>> If no rpcmount mountoption, no rpc_pipefs was found at
>>> '/var/lib/nfs/rpc_pipefs' and we are in init's mount namespace, we use
>>> init_rpc_pipefs.
>>
>> It's the "we are in init's mount namespace" that I was wondering about.
>>
>> So if I naievely chroot, nfs mount stops working the way it did before I
>> chrooted unless I do an extra setup step?
>
> No. It will work as before since you are still in init's mount namespace.
> Creating new mount namespace changes rules.

Ah, CLONE_NEWNS and then you need /var/lib/nfs/rpc_pipefs.  Got it.

I'm kind of surprised that the kernel cares about a specific path under 
/var/lib.  (Seems like policy in the kernel somehow.)  Can't it just 
check the current process's mount list to see if an instance of 
rpc_pipefs is mounted in the current namespace the way lxc looks for 
cgroups?  Or are there potential performance/scalability issues with that?

Rob
