Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:39948 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480Ab2GYKeW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jul 2012 06:34:22 -0400
Message-ID: <500FCBA7.7000909@parallels.com>
Date: Wed, 25 Jul 2012 14:34:15 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3 00/11] Series short description
References: <20120703161844.11911.92996.stgit@localhost.localdomain> <20120724223617.GP8570@fieldses.org>
In-Reply-To: <20120724223617.GP8570@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

25.07.2012 02:36, J. Bruce Fields пишет:
> On Tue, Jul 03, 2012 at 08:19:23PM +0400, Stanislav Kinsbursky wrote:
>> v3: Rebased on Bruce's tree, "for-3.6" branch
>>
>> v2: Rebased on Bruce's tree, "for-3.5" branch
>
> Aside from the one question, this looks OK to me.
>
> I seem to recall this needed to go through my tree for some reason, but
> does Trond still want a chance to ACK/NACK it?
>

Agreed.
Trond, could you, please, review this patch set?
And maybe it's better to push this code through your tree to simplify further 
merging?

> --b.
>
>>
>> This patch set depeneds on "SUNRPC: separate per-net data creation from
>> service
>> creation" patch set sent earlier.
>>
>> The following series implements...
>>
>> ---
>>
>> Stanislav Kinsbursky (11):
>>        NFS: pass net to nfs_callback_down()
>>        NFS: callback service creation function introduced
>>        NFS: move per-net callback thread initialization to nfs_callback_up_net()
>>        NFS: callback up - transport backchannel cleanup
>>        NFS: callback service start function introduced
>>        NFS: callback up - users counting cleanup
>>        NFS: make nfs_callback_tcpport per network context
>>        NFS: make nfs_callback_tcpport6 per network context
>>        NFS; callback per-net usage counting introduced
>>        NFS: add debug messages to callback down function
>>        NFS: get net after idr allocation
>>
>>
>>   fs/nfs/callback.c  |  288 ++++++++++++++++++++++++++++++++++------------------
>>   fs/nfs/callback.h  |    4 -
>>   fs/nfs/client.c    |    5 +
>>   fs/nfs/netns.h     |    3 +
>>   fs/nfs/nfs4state.c |    6 +
>>   5 files changed, 202 insertions(+), 104 deletions(-)
>>


-- 
Best regards,
Stanislav Kinsbursky


