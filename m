Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:21345 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752698Ab2ALIqE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jan 2012 03:46:04 -0500
Message-ID: <4F0E9DA5.5060505@parallels.com>
Date: Thu, 12 Jan 2012 12:45:25 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v2 4/5] NFS: remove RPC PipeFS mount point reference from
 blocklayout routines
References: <20120110130323.1672.97025.stgit@localhost6.localdomain6>	 <20120110130440.1672.43785.stgit@localhost6.localdomain6>	 <1326306793.20284.3.camel@lade.trondhjem.org> <1326306977.20284.4.camel@lade.trondhjem.org>
In-Reply-To: <1326306977.20284.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.01.2012 22:36, Trond Myklebust пишет:
> On Wed, 2012-01-11 at 13:33 -0500, Trond Myklebust wrote:
>> On Tue, 2012-01-10 at 17:04 +0400, Stanislav Kinsbursky wrote:
>>> This is a cleanup patch. We don't need this reference anymore, because
>>> blocklayout pipes dentries now creates and destroys in per-net operations and
>>> on PipeFS mount/umount notification.
>>> Note that nfs4blocklayout_register_net() now returns 0 instead of -ENOENT in
>>> case of PipeFS superblock absence. This is ok, because blocklayout pipe dentry
>>> will be created on PipeFS mount event.
>>>
>>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>
>>> ---
>>>   fs/nfs/blocklayout/blocklayout.c |    9 +--------
>>>   1 files changed, 1 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
>>> index 322d920..2c70202 100644
>>> --- a/fs/nfs/blocklayout/blocklayout.c
>>> +++ b/fs/nfs/blocklayout/blocklayout.c
>>> @@ -1034,7 +1034,7 @@ static struct dentry *nfs4blocklayout_register_net(struct net *net,
>>>
>>>   	pipefs_sb = rpc_get_sb_net(net);
>>>   	if (!pipefs_sb)
>>> -		return ERR_PTR(-ENOENT);
>>> +		return 0;
>>
>> This looks like a typo of some sort. The caller in
>> nfs4blocklayout_net_init() checks for IS_ERR(), not NULL. I'll just
>> remove this hunk...
>
> Never mind. I see what's going on now... It should be NULL, and not 0
> for coding style reasons, though...
>

Yep, NULL of course, sorry.

-- 
Best regards,
Stanislav Kinsbursky
