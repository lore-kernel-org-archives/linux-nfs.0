Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33640 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751515AbdDCJka (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Apr 2017 05:40:30 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>, bfields@fieldses.org,
        "Miklos Szeredi" <miklos@szeredi.hu>,
        "Alexander Viro" <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 5/6] lockd: Introduce nlmclnt_operations
Date: Mon, 03 Apr 2017 05:40:12 -0400
Message-ID: <4B6207B9-7254-4C1A-81AF-5DC7B0C74F94@redhat.com>
In-Reply-To: <1491055532.18117.6.camel@redhat.com>
References: <cover.1491015671.git.bcodding@redhat.com>
 <c2c20de92b177386ad627726b6b2838569c2b28d.1491015671.git.bcodding@redhat.com>
 <1491055532.18117.6.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 1 Apr 2017, at 10:05, Jeff Layton wrote:

> On Fri, 2017-03-31 at 23:16 -0400, Benjamin Coddington wrote:
>> NFS would enjoy the ability to modify the behavior of the NLM 
>> client's
>> unlock RPC task in order to delay the transmission of the unlock 
>> until IO
>> that was submitted under that lock has completed.  This ability can 
>> ensure
>> that the NLM client will always complete the transmission of an 
>> unlock even
>> if the waiting caller has been interrupted with fatal signal.
>>
>> A struct nlmclnt_operations and callback data pointer can be passed 
>> to
>> nlmclnt_proc(). The struct nlmclnt_operations defines three callback
>> operations that will be used in a following patch:
>>
>> nlmclnt_alloc_call - used to call back after a successful allocation 
>> of
>> 	a struct nlm_rqst in nlmclnt_proc().
>>
>> nlmclnt_unlock_prepare - used to call back during NLM unlock's
>> 	rpc_call_prepare.  The NLM client defers calling rpc_call_start()
>> 	until this callback returns false.
>>
>> nlmclnt_release_call - used to call back when the NLM client's struct
>> 	nlm_rqst is freed.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>>  fs/lockd/clntproc.c         | 26 +++++++++++++++++++++++++-
>>  fs/nfs/nfs3proc.c           |  2 +-
>>  fs/nfs/proc.c               |  2 +-
>>  include/linux/lockd/bind.h  | 11 +++++++++--
>>  include/linux/lockd/lockd.h |  2 ++
>>  5 files changed, 38 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
>> index 112952037933..d2744f4960ed 100644
>> --- a/fs/lockd/clntproc.c
>> +++ b/fs/lockd/clntproc.c
>> @@ -150,9 +150,12 @@ static void nlmclnt_release_lockargs(struct 
>> nlm_rqst *req)
>>   * @host: address of a valid nlm_host context representing the NLM 
>> server
>>   * @cmd: fcntl-style file lock operation to perform
>>   * @fl: address of arguments for the lock operation
>> + * @nlmclnt_ops: operations to call back out of nlm
>> + * @data: address of data to be sent along with callback
>>   *
>>   */
>> -int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock 
>> *fl)
>> +int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock 
>> *fl,
>> +		const struct nlmclnt_operations *nlmclnt_ops, void *data)
>
> Might it be cleaner to put the nlmclnt_operations into the nlm_host?
> Could pass a pointer to it in the nlmclnt_initdata when creating the
> nfs_server.

Maybe, if 5 args here is too much.  But passing nlmclnt_operations into
nlm_init in nfs_start_lockd() would mean the function pointers in
nlmclnt_operations would need to be exposed in client.c.  While this has
more args, I think it is a bit neater from the NFS side.

Ben
