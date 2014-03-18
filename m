Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756951AbaCRRY1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Mar 2014 13:24:27 -0400
Message-ID: <53288146.4010601@RedHat.com>
Date: Tue, 18 Mar 2014 13:24:22 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] SUNRPC: Ensure that call_connect times out correctly
References: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com> <53286A9D.2020007@RedHat.com> <362845B0-35A4-4DDF-96F6-42582D66334B@primarydata.com>
In-Reply-To: <362845B0-35A4-4DDF-96F6-42582D66334B@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/18/2014 11:58 AM, Trond Myklebust wrote:
> 
> On Mar 18, 2014, at 11:47, Steve Dickson <SteveD@redhat.com> wrote:
> 
>> Hey,
>>
>> On 03/17/2014 02:40 PM, Trond Myklebust wrote:
>>> When the server is unavailable due to a networking error, etc, we want
>>> the RPC client to respect the timeout delays when attempting to reconnect.
>>>
>>> Fixes: 561ec1603171 (SUNRPC: call_connect_status should recheck bind..)
>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>> ---
>>> net/sunrpc/clnt.c | 8 +++-----
>>> 1 file changed, 3 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>> index 0edada973434..f22d3a115fda 100644
>>> --- a/net/sunrpc/clnt.c
>>> +++ b/net/sunrpc/clnt.c
>>> @@ -1798,10 +1798,6 @@ call_connect_status(struct rpc_task *task)
>>> 	trace_rpc_connect_status(task, status);
>>> 	task->tk_status = 0;
>>> 	switch (status) {
>>> -		/* if soft mounted, test if we've timed out */
>>> -	case -ETIMEDOUT:
>>> -		task->tk_action = call_timeout;
>>> -		return;
>>> 	case -ECONNREFUSED:
>>> 	case -ECONNRESET:
>>> 	case -ECONNABORTED:
>>> @@ -1812,7 +1808,9 @@ call_connect_status(struct rpc_task *task)
>>> 		if (RPC_IS_SOFTCONN(task))
>>> 			break;
>>> 	case -EAGAIN:
>>> -		task->tk_action = call_bind;
>>> +	case -ETIMEDOUT:
>>> +		/* Check if we've timed out before looping back to call_bind */
>>> +		task->tk_action = call_timeout;
>>> 		return;
>>> 	case 0:
>>> 		clnt->cl_stats->netreconn++;
>>>
>> How is this support to work if the trunking code still ignores timeouts? 
>>
>> [ 2076.045176] NFS: nfs4_discover_server_trunking after status -110, retrying
> 
> The above patch fixes the regression that Neil tracked down in Linux 3.12, and that 
> affects the generic RPC handling of soft timeouts.
> 
> The trunking code's handling of ETIMEDOUT has been there since Linux 3.7 
> and hasn’t changed, so I really don’t see how it can have worked at one time before 3.12.
Maybe it been broken that long.... :-) 

But here is the obvious loop that stop that hangs a mount forever:

 #8 [ffff88007a22b7e8] rpc_call_sync at ffffffffa0220210 [sunrpc]
 #9 [ffff88007a22b840] nfs4_proc_setclientid at ffffffffa0505c49 [nfsv4]
#10 [ffff88007a22b988] nfs40_discover_server_trunking at ffffffffa0514489 [nfsv4]
#11 [ffff88007a22b9d0] nfs4_discover_server_trunking at ffffffffa0516f2d [nfsv4]
#12 [ffff88007a22ba28] nfs4_init_client at ffffffffa051e9a4 [nfsv4]
#13 [ffff88007a22bb20] nfs_get_client at ffffffffa04bd6ba [nfs]
#14 [ffff88007a22bb80] nfs4_set_client at ffffffffa051dfb0 [nfsv4]
#15 [ffff88007a22bc00] nfs4_create_server at ffffffffa051f4ce [nfsv4]
#16 [ffff88007a22bc88] nfs4_remote_mount at ffffffffa051790e [nfsv4]
#17 [ffff88007a22bcb0] mount_fs at ffffffff811b3dd9

The SETCLIENT times out 
   NFS call  setclientid auth=UNIX, 'Linux NFSv4.0 10.19.60.77/10.19.60.33 tcp'
   NFS reply setclientid: -110

The nfs4_discover_server_trunking() retries 
   NFS: nfs4_discover_server_trunking after status -110, retrying

The happens when there server is down and so the connections 
fail with ECONNREFUSED:
   RPC:     2 call_connect_status (status -111)

The mount system call never times out in which it did in the past. 

So who do I get the system call to time out again?

steved.

