Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:45427 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbaAIHPR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 02:15:17 -0500
Message-ID: <52CE4C7E.1030801@parallels.com>
Date: Thu, 9 Jan 2014 11:15:10 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <wengmeiling.weng@huawei.com>, <greg@kroah.com>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [PATCH] nfsd: check passed socket's net matches NFSd superblock's
 one
References: <20131230142339.16166.28243.stgit@localhost.localdomain> <20140103222226.GD5164@fieldses.org>
In-Reply-To: <20140103222226.GD5164@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

04.01.2014 02:22, J. Bruce Fields пишет:
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

Correct.

-- 
Best regards,
Stanislav Kinsbursky
