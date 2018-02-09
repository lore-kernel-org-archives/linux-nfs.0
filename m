Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:46666 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751034AbeBIPsv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Feb 2018 10:48:51 -0500
Subject: Re: [PATCH] nfs: system crashes after NFS4ERR_MOVED recovery
To: Trond Myklebust <trondmy@primarydata.com>,
        "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <307dc174-b2d0-461a-fc76-193711f150d2@Oracle.com>
 <1518037638.56541.2.camel@primarydata.com>
 <1518038401.56541.6.camel@primarydata.com>
From: Bill Baker <Bill.Baker@Oracle.com>
Message-ID: <f5500297-5e11-c8ec-f4be-eef0da203d6e@Oracle.com>
Date: Fri, 9 Feb 2018 09:49:10 -0600
MIME-Version: 1.0
In-Reply-To: <1518038401.56541.6.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/07/2018 03:20 PM, Trond Myklebust wrote:
> On Wed, 2018-02-07 at 16:07 -0500, Trond Myklebust wrote:
>> Hi Bill,
>>
>> On Wed, 2018-02-07 at 14:53 -0600, Bill Baker wrote:
>>> nfs4_update_server unconditionally releases the nfs_client for the
>>> source server. If migration fails, this can cause the source
>>> server's
>>> nfs_client struct to be left with a low reference count, resulting
>>> in
>>> use-after-free.
>>>
>>> NFS: state manager: migration failed on NFSv4 server nfsvmu10 with
>>> error 6
>>> WARNING: CPU: 16 PID: 17960 at fs/nfs/client.c:281
>>> nfs_put_client+0xfa/0x110 [nfs]()
>>>           nfs_put_client+0xfa/0x110 [nfs]
>>>           nfs4_run_state_manager+0x30/0x40 [nfsv4]
>>>           kthread+0xd8/0xf0
>>>
>>> BUG: unable to handle kernel NULL pointer dereference at
>>> 00000000000002a8
>>>           nfs4_xdr_enc_write+0x6b/0x160 [nfsv4]
>>>           rpcauth_wrap_req+0xac/0xf0 [sunrpc]
>>>           call_transmit+0x18c/0x2c0 [sunrpc]
>>>           __rpc_execute+0xa6/0x490 [sunrpc]
>>>           rpc_async_schedule+0x15/0x20 [sunrpc]
>>>           process_one_work+0x160/0x470
>>>           worker_thread+0x112/0x540
>>>           kthread+0xd8/0xf0
>>>
>>> Reported-by: Helen Chao <helen.chao@oracle.com>
>>> Fixes: 32e62b7c3ef0 ("NFS: Add nfs4_update_server")
>>> Signed-off-by: Bill Baker <bill.baker@oracle.com>
>>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>    fs/nfs/nfs4client.c | 2 +-
>>>    1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>>> index 65a7e5d..c818cdd 100644
>>> --- a/fs/nfs/nfs4client.c
>>> +++ b/fs/nfs/nfs4client.c
>>> @@ -1226,11 +1226,11 @@ int nfs4_update_server(struct nfs_server
>>> *server, const char *hostname,
>>>                                   clp->cl_proto, clnt->cl_timeout,
>>>                                   clp->cl_minorversion, net);
>>>           clear_bit(NFS_MIG_TSM_POSSIBLE, &server->mig_status);
>>> -       nfs_put_client(clp);
>>>           if (error != 0) {
>>>                   nfs_server_insert_lists(server);
>>>                   return error;
>>>           }
>>> +       nfs_put_client(clp);
>>>
>>>           if (server->nfs_client->cl_hostname == NULL)
>>>                   server->nfs_client->cl_hostname =
>>> kstrdup(hostname,
>>> GFP_KERNEL);
>>>
>>
>> That looks almost right. Isn't there now a reference leak if
>> nfs4_set_client() returns -ELOOP? I think that is really down to an
>> existing bug in nfs4_set_client() rather than in your fix, however
> 
> Sorry... I should probably have been more explicit about where the bug
> is: nfs4_set_client() should probably be calling nfs_put_client() on
> its copy of 'clp' before returning -ELOOP.
> 
>> the
>> fix does re-expose that bug.
> 
> By which I mean that the two bugs currently cancel each other out for
> the case of ELOOP. By fixing one bug, but not the other, we're undoing
> the cancellation... ☺
> 

Ah, yes, I see.

         if (server->nfs_client == clp) {
                 nfs_put_client(clp);
                 return -ELOOP;
         }

I'll send an updated patch shortly.  Thanks for your feedback.


-- 
Bill Baker - Oracle Linux NFS
