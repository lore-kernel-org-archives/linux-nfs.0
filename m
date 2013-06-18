Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:38000 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab3FRGmE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jun 2013 02:42:04 -0400
Message-ID: <51C00116.2080301@parallels.com>
Date: Tue, 18 Jun 2013 10:41:26 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH v2 2/4] SUNRPC: fix races on PipeFS MOUNT notifications
References: <20130611143725.16046.17279.stgit@localhost.localdomain>  <20130611143917.16046.15791.stgit@localhost.localdomain> <1371493226.9595.5.camel@leira.trondhjem.org>
In-Reply-To: <1371493226.9595.5.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

17.06.2013 22:20, Myklebust, Trond пишет:
> On Tue, 2013-06-11 at 18:39 +0400, Stanislav Kinsbursky wrote:
>> Below are races, when RPC client can be created without PiepFS dentries
>>
>> CPU#0					CPU#1
>> -----------------------------		-----------------------------
>> rpc_new_client				rpc_fill_super
>> rpc_setup_pipedir
>> mutex_lock(&sn->pipefs_sb_lock)
>> rpc_get_sb_net == NULL
>> (no per-net PipeFS superblock)
>> 					sn->pipefs_sb = sb;
>> 					notifier_call_chain(MOUNT)
>> 					(client is not in the list)
>> rpc_register_client
>> (client without pipes dentries)
>>
>> To fix this patch:
>> 1) makes PipeFS mount notification call with pipefs_sb_lock being held.
>> 2) releases pipefs_sb_lock on new SUNRPC client creation only after
>> registration.
>>
>> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
>> Cc: stable@vger.kernel.org
>
> Hi Stanislav,
>
> This isn't going to apply to the stable kernels without the cleanup
> patch. Could you please reorganise this patch series so that the cleanup
> comes last.
>
> Thanks,
>    Trond
>
>

Hello, Trond.
Sure, will do.

-- 
Best regards,
Stanislav Kinsbursky
