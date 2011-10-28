Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:6665 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754029Ab1J1JYH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 05:24:07 -0400
Message-ID: <4EAA74DD.3070708@parallels.com>
Date: Fri, 28 Oct 2011 13:24:45 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3 0/3] SUNRPC: rcbind clients virtualization
References: <20111027180824.20459.23219.stgit@localhost6.localdomain6> <20111027202514.GA31669@fieldses.org>
In-Reply-To: <20111027202514.GA31669@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

28.10.2011 00:25, J. Bruce Fields пишет:
> On Thu, Oct 27, 2011 at 10:10:43PM +0300, Stanislav Kinsbursky wrote:
>> v3:
>> 1) First two patches from previous version were squashed.
>>
>> This patch-set was created in context of clone of git branch:
>> git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git
>> and rebased on tag "v3.1".
>>
>> This patch-set virtualizes rpcbind clients per network namespace context. IOW,
>> each network namespace will have its own pair of rpcbind clients (if they would
>> be created by request).
>>
>> Note:
>> 1) this patch-set depends on "SUNRPC: make rpcbind clients allocated and
>> destroyed dynamically" patch-set which has been send earlier.
>> 2) init_net pointer is still used instead of current->nsproxy->net_ns,
>> because I'm not sure yet about how to virtualize services. I.e. NFS callback
>> services will be per netns. NFSd service will be per netns too from my pow. But
>> Lockd can be per netns or one for all.
>
> I'm not sure what you mean by that; could you explain?
>

This patch-set was created before you've sent your NFSd plan and we disacussed 
Lockd per netns.
So, this sentence: "NFSd service will be per netns too from my pow" is obsolete. 
And Lockd will be one for all.
Or you are asking about something else?

> --b.
>
>> And also we have NFSd file system, which
>> is not virtualized yet.
>>
>> The following series consists of:
>>
>> ---
>>
>> Stanislav Kinsbursky (3):
>>        SUNRPC: move rpcbind internals to sunrpc part of network namespace context
>>        SUNRPC: optimize net_ns dereferencing in rpcbind creation calls
>>        SUNRPC: optimize net_ns dereferencing in rpcbind registering calls
>>
>>
>>   net/sunrpc/netns.h     |    5 ++
>>   net/sunrpc/rpcb_clnt.c |  103 ++++++++++++++++++++++++++----------------------
>>   2 files changed, 61 insertions(+), 47 deletions(-)
>>
>> --
>> Signature


-- 
Best regards,
Stanislav Kinsbursky
