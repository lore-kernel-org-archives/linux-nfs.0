Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:41024 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952Ab1LLQOT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 11:14:19 -0500
Message-ID: <4EE62824.9090807@parallels.com>
Date: Mon, 12 Dec 2011 20:13:24 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 0/4] SUNRPC: pass network namespace context to sockaddr
 construction routines
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6> <20111208204648.GB32505@fieldses.org>
In-Reply-To: <20111208204648.GB32505@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

09.12.2011 00:46, J. Bruce Fields пишет:
> On Wed, Dec 07, 2011 at 03:20:07PM +0300, Stanislav Kinsbursky wrote:
>> This is another precursor patch set aimed to remove hard-coded "init_net"
>> reference from SUNRPC sockaddr convertion and construction routines.
>
> ACK--all look straightforward.  (Only complaint would be that this isn't
> terribly interesting till we see how these are used.)
>

Actually, all is simple. These init_net pointers will be replaced later by 
"transports, clients and others" network namespace contexts.
I have some more patches for NFS layer. But I don't see any sense to sent them 
now since no "virtualization" patches were commited yet.
So, currently, I'm trying to finalize "SUNRPC per network namespace" task, and 
soon I'll send a patch set making SUNRPC sysctl's network-namespace-aware. It is 
a little bit tricky and ugly from my pow, so any ideas are welcome.

> --b.
>
>
>>
>> The following series consists of:
>>
>> ---
>>
>> Stanislav Kinsbursky (4):
>>        SUNRPC: use passed network namespace context in rpc_parse_scope_id()
>>        SUNRPC: use passed network namespace context in rpc_pton6()
>>        SUNRPC: use passed network namespace context in rpc_pton()
>>        SUNRPC: use passed network namespace context in rpc_uaddr2sockaddr()
>>
>>
>>   fs/nfs/dns_resolve.c        |    4 ++--
>>   fs/nfs/nfs4filelayoutdev.c  |    2 +-
>>   fs/nfs/nfs4namespace.c      |    2 +-
>>   fs/nfs/super.c              |    4 ++--
>>   fs/nfsd/nfs4state.c         |    2 +-
>>   fs/nfsd/nfsctl.c            |    2 +-
>>   include/linux/sunrpc/clnt.h |    4 ++--
>>   net/sunrpc/addr.c           |   24 +++++++++++++-----------
>>   net/sunrpc/rpcb_clnt.c      |    2 +-
>>   net/sunrpc/svcauth_unix.c   |    2 +-
>>   10 files changed, 25 insertions(+), 23 deletions(-)
>>
>> --
>> Signature


-- 
Best regards,
Stanislav Kinsbursky
