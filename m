Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51504 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750698AbcH3NGK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Aug 2016 09:06:10 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>,
        "Schumaker Anna" <anna.schumaker@netapp.com>
Subject: Re: [PATCH] NFS4: Avoid migration loops
Date: Tue, 30 Aug 2016 09:06:07 -0400
Message-ID: <D0D7F156-6AB4-43F4-8E15-533CB0EC09EF@redhat.com>
In-Reply-To: <5B8891FB-1A45-4398-8881-5D72B1C250D7@primarydata.com>
References: <C654261E-107D-4CB0-A345-E45BC4401F65@redhat.com>
 <5B8891FB-1A45-4398-8881-5D72B1C250D7@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 30 Aug 2016, at 8:53, Trond Myklebust wrote:

>> On Aug 30, 2016, at 07:13, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>>
>> If a server returns itself as a location while migrating the client 
>> may
>> end up getting stuck attempting to migrate twice to the same server.  
>> Catch
>> this by checking if the nfs_client found is the same as the existing
>> client.  For the other two callers to nfs4_set_client, the nfs_client 
>> will
>> always be ERR_PTR(-EINVAL);
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>> fs/nfs/nfs4client.c | 6 ++++++
>> 1 file changed, 6 insertions(+)
>>
>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>> index 8d7d08d4f95f..ec8afc43d849 100644
>> --- a/fs/nfs/nfs4client.c
>> +++ b/fs/nfs/nfs4client.c
>> @@ -817,6 +817,12 @@ static int nfs4_set_client(struct nfs_server 
>> *server,
>> 		goto error;
>> 	}
>>
>> +	/* This client is already set, is there a migration loop? */
>> +	if (server->nfs_client == clp) {
>> +		error = -EEXIST;
>> +		goto error;
>> +	}
>> +
>
> Good catch, but why the choice of EEXIST? It sounds as if there is a 
> good
> argument for ELOOP, since this situation would literally mirror the
> self-referencing symlink case.

I thought EEXIST more indicative of what nfs4_set_client() was noticing 
in
the local context, but I'll send you a v2 with ELOOP.  That will also be
more informative when the state manager logs the migration failure.

Ben
