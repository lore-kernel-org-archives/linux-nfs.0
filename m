Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ve1eur01on0094.outbound.protection.outlook.com ([104.47.1.94]:19776
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752413AbeCOOqp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Mar 2018 10:46:45 -0400
Subject: Re: [PATCH net-next nfs 0/6] Converting pernet_operations (part #7)
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: davem@davemloft.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, jlayton@kernel.org, dhowells@redhat.com,
        keescook@chromium.org, dwindsor@gmail.com, ishkamiel@gmail.com,
        elena.reshetova@intel.com, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
 <e9612f81-0306-6f87-2ad5-c79b848eafae@virtuozzo.com>
 <20180315142452.GA17336@fieldses.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <a47a92c6-7242-3a73-9ad4-a71eca5a5b46@virtuozzo.com>
Date: Thu, 15 Mar 2018 17:46:38 +0300
MIME-Version: 1.0
In-Reply-To: <20180315142452.GA17336@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 15.03.2018 17:24, J. Bruce Fields wrote:
> On Thu, Mar 15, 2018 at 04:32:30PM +0300, Kirill Tkhai wrote:
>> Trond, Anna, Bruce, Jeff, David and other NFS and RXRPC people,
>> could you please provide your vision on this patches?
> 
> Whoops, sorry, I haven't been paying attention.  Do you have a pointer
> to documentation?  I'm unclear what the actual concurrency change
> is--sounds like it becomes possible that e.g. multiple ->init methods
> (from the same pernet_operations but for different namespaces) could run
> in parallel?

There is a commentary near struct pernet_operations in fresh net-next.git:

struct pernet_operations {
        struct list_head list;
        /*
         * Below methods are called without any exclusive locks.
         * More than one net may be constructed and destructed
         * in parallel on several cpus. Every pernet_operations
         * have to keep in mind all other pernet_operations and
         * to introduce a locking, if they share common resources.
         *
         * Exit methods using blocking RCU primitives, such as
         * synchronize_rcu(), should be implemented via exit_batch.
         * Then, destruction of a group of net requires single
         * synchronize_rcu() related to these pernet_operations,
         * instead of separate synchronize_rcu() for every net.
         * Please, avoid synchronize_rcu() at all, where it's possible.
         */

I hope this is enough. Please tell me, if there is unclear thing, I'll
extend it.
 
> Sounds likely to be safe, and I don't actually care too much who merges
> them as they look very unlikely to conflict with anything pending.  But
> unless anyone tells me otherwise I'll take the one nfsd_net_ops patch
> and leave the rest to Anna or Trond.

Sounds great. Thanks!

Kirill

>> Thanks,
>> Kirill
>>
>> On 13.03.2018 13:49, Kirill Tkhai wrote:
>>> Hi,
>>>
>>> this series continues to review and to convert pernet_operations
>>> to make them possible to be executed in parallel for several
>>> net namespaces in the same time. There are nfs pernet_operations
>>> in this series. All of them look similar each other, they mostly
>>> create and destroy caches with small exceptions.
>>>
>>> Also, there is rxrpc_net_ops, which is used in AFS.
>>>
>>> Thanks,
>>> Kirill
>>> ---
>>>
>>> Kirill Tkhai (6):
>>>       net: Convert rpcsec_gss_net_ops
>>>       net: Convert sunrpc_net_ops
>>>       net: Convert nfsd_net_ops
>>>       net: Convert nfs4_dns_resolver_ops
>>>       net: Convert nfs4blocklayout_net_ops
>>>       net: Convert rxrpc_net_ops
>>>
>>>
>>>  fs/nfs/blocklayout/rpc_pipefs.c |    1 +
>>>  fs/nfs/dns_resolve.c            |    1 +
>>>  fs/nfsd/nfsctl.c                |    1 +
>>>  net/rxrpc/net_ns.c              |    1 +
>>>  net/sunrpc/auth_gss/auth_gss.c  |    1 +
>>>  net/sunrpc/sunrpc_syms.c        |    1 +
>>>  6 files changed, 6 insertions(+)
>>>
>>> --
>>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>>>
