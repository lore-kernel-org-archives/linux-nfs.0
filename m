Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61629 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753262Ab2HGPw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 11:52:56 -0400
Message-ID: <502139D6.7060704@netapp.com>
Date: Tue, 07 Aug 2012 11:52:54 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joro@8bytes.org" <joro@8bytes.org>,
        "mdauchy@gmail.com" <mdauchy@gmail.com>
Subject: Re: [PATCH] NFS: Clear key construction data if the idmap upcall
 fails
References: <1344353431-28831-1-git-send-email-bjschuma@netapp.com> <1344354243.5781.20.camel@lade.trondhjem.org>
In-Reply-To: <1344354243.5781.20.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/07/2012 11:44 AM, Myklebust, Trond wrote:
> On Tue, 2012-08-07 at 11:30 -0400, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> idmap_pipe_downcall already clears this field if the upcall succeeds,
>> but if it fails (rpc.idmapd isn't running) the field will still be set
>> on the next call triggering a BUG_ON().
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>>  fs/nfs/idmap.c | 16 +++++++++-------
>>  1 file changed, 9 insertions(+), 7 deletions(-)
>>
>> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
>> index b701358..645cfe7 100644
>> --- a/fs/nfs/idmap.c
>> +++ b/fs/nfs/idmap.c
>> @@ -683,10 +683,12 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
>>  
>>  	ret = rpc_queue_upcall(idmap->idmap_pipe, msg);
>>  	if (ret < 0)
>> -		goto out2;
>> +		goto out3;
>>  
>>  	return ret;
>>  
>> +out3:
>> +	idmap->idmap_key_cons = NULL;
>>  out2:
>>  	kfree(im);
>>  out1:
> 
> That fixes rpc_queue_upcall failure path, but we still need to deal with
> timeouts and close.
> 
> How about the following alternative:
> 
> Set idmap->idmap_key_cons after grabbing the mutex in
> nfs_idmap_get_key(), then clear it before you release that mutex. That

The key construction data doesn't exist during nfs_idmap_get_key().  request_key() sets it up to pass to our functions as it works through the keyrings code.

- Bryan

> leaves one possible race in which the idmap->idmap_key_cons is cleared
> while we're in idmap_pipe_downcall. One way to solve that race is to use
> a second mutex (see the original idmapper design from before your
> changes) to ensure that nothing clears idmap_key_cons while we're in
> idmap_pipe_downcall.
> 

