Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:9933 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965190Ab3HHO0h convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Aug 2013 10:26:37 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Andy Adamson <androsadamson@gmail.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 1/6] NFSv4.1 Fix an rpc client leak
Date: Thu, 8 Aug 2013 14:26:36 +0000
Message-ID: <42DD7001-4DDD-4F74-8488-F9AEFFB20768@netapp.com>
References: <1375906192-1988-1-git-send-email-andros@netapp.com>
 <1375907551.7280.57.camel@leira.trondhjem.org>
 <CAHVgHyWFY4UNjoei6dsLkMejePPdbDapr+-E7ZO=BqPHZUSc4w@mail.gmail.com>
 <1375923513.26965.2.camel@leira.trondhjem.org>
In-Reply-To: <1375923513.26965.2.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 7, 2013, at 8:58 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Wed, 2013-08-07 at 17:26 -0400, Andy Adamson wrote:
>> 
>> 
>> 
>> On Wed, Aug 7, 2013 at 4:32 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>>        On Wed, 2013-08-07 at 16:09 -0400, andros@netapp.com wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>> 
>>> nfs4_proc_lookup_mountpoint clones an rpc client to perform
>>        a lookup across
>>> a mountpoint. If the security of the mountpoint is different
>>        than that of
>>> the clonded rpc client, a secinfo query is sent, and if
>>        successful, a new
>>> rpc client is cloned an returned to
>>        nfs4_proc_lookup_mountpoint replacing
>>> the original cloned client pointer. In this case, the
>>        originoal cloned client
>>> is not reaped - which results in a leak of multiple rpc
>>        clients, as the
>>> parent of the original cloned client will not be
>>        dereferenced, and it's
>>> parent will not be dereferenced...
>>> 
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>> fs/nfs/nfs4proc.c | 3 +++
>>> 1 file changed, 3 insertions(+)
>>> 
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 0e64ccc..ee30a4f 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -3073,12 +3073,15 @@ nfs4_proc_lookup_mountpoint(struct
>>        inode *dir, struct qstr *name,
>>> {
>>>      int status;
>>>      struct rpc_clnt *client =
>>        rpc_clone_client(NFS_CLIENT(dir));
>>> +     struct rpc_clnt *clnt = client;
>>> 
>>>      status = nfs4_proc_lookup_common(&client, dir, name,
>>        fhandle, fattr, NULL);
>>>      if (status < 0) {
>>>              rpc_shutdown_client(client);
>>>              return ERR_PTR(status);
>>>      }
>>> +     if (clnt != client)
>>> +             rpc_shutdown_client(clnt);
>>>      return client;
>>> }
>>> 
>> 
>>        Wouldn't that shut down the client that still belongs to
>>        NFS_SERVER(dir)?
>> 
>> 
>> No. It shuts down a _clone_ of the client that still belongs to
>> NFS_SERVER(dir).
>> 
> 
> OK. However how about the case where rpc_clone_client() returns an
> error? As far as I can tell neither the fix nor the original code deals
> with that case.
> How about something like the following, where we defer the clone until
> we know that it might be needed?

Looks good. Testing verifies it works.

-->Andy

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> <0001-NFSv4-Fix-up-nfs4_proc_lookup_mountpoint.patch>

