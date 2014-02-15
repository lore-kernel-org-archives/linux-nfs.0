Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:35754 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbaBOBwJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Feb 2014 20:52:09 -0500
Message-ID: <52FEC818.7030604@huawei.com>
Date: Sat, 15 Feb 2014 09:51:20 +0800
From: Weng Meiling <wengmeiling.weng@huawei.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Stanislav Kinsbursky <skinsbursky@parallels.com>, <greg@kroah.com>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [PATCH] nfsd: check passed socket's net matches NFSd superblock's
 one
References: <20131230142339.16166.28243.stgit@localhost.localdomain> <20140103222226.GD5164@fieldses.org>
In-Reply-To: <20140103222226.GD5164@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

The upstream has merged your git tree for-3.14, but there is no this patch?
Do you forget this patch?

Thanks!
Weng Meiling


On 2014/1/4 6:22, J. Bruce Fields wrote:
> On Mon, Dec 30, 2013 at 05:23:59PM +0300, Stanislav Kinsbursky wrote:
>> There could be a case, when NFSd file system is mounted in network, different
>> to socket's one, like below:
>>
>> "ip netns exec" creates new network and mount namespace, which duplicates NFSd
>> mount point, created in init_net context. And thus NFS server stop in nested
>> network context leads to RPCBIND client destruction in init_net.
>> Then, on NFSd start in nested network context, rpc.nfsd process creates socket
>> in nested net and passes it into "write_ports", which leads to RPCBIND sockets
>> creation in init_net context because of the same reason (NFSd monut point was
>> created in init_net context). An attempt to register passed socket in nested
>> net leads to panic, because no RPCBIND client present in nexted network
>> namespace.
> 
> So it's the attempt to use a NULL ->rpcb_local_clnt4?
> 
> Interesting, thanks--applying with a minor fix to logged message.
> 
> --b.
> 



