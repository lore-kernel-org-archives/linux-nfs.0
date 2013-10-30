Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f181.google.com ([74.125.82.181]:40198 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754581Ab3J3ORE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Oct 2013 10:17:04 -0400
Received: by mail-we0-f181.google.com with SMTP id t60so1378341wes.12
        for <linux-nfs@vger.kernel.org>; Wed, 30 Oct 2013 07:17:02 -0700 (PDT)
Message-ID: <527114DB.1050803@primarydata.com>
Date: Wed, 30 Oct 2013 16:16:59 +0200
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/7] nfsd4: move nfs4_put_file from unhash to put delegation
References: <526F81DE.6060704@primarydata.com> <1383039572-27405-1-git-send-email-bhalevy@primarydata.com> <20131029155906.GV31322@fieldses.org>
In-Reply-To: <20131029155906.GV31322@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-29 17:59, J. Bruce Fields wrote:
> On Tue, Oct 29, 2013 at 11:39:32AM +0200, Benny Halevy wrote:
>> revoked delegations are unhashed but are kept around in nfsv4.1	and we better
>> hang on to dp_file in this case.
> 
> I don't agree: we shouldn't need dl_file any more once the delegation is
> revoked.  It exists only to process delegreturns and set
> SEQ4_STATUS_RECALLABLE_STATE_REVOKED.

OK, makes sense.

> 
> If some other code (like delegreturn) *is* attempting to use dl_file on
> revoked delegation, then that sounds like a delegreturn bug.

It doesn't seem so.

> 
> Among other things I think we'd like to be able to free up the reference
> and deallocate the file on disk if necessary once the delegation has
> been revoked.

OK, I'll deal with blocking case in my patchset, but putting the file will
need to beseparated from unhashing as the latter will be done under a spin lock
and put_nfs4_file -> iput may block.

Benny

> 
> --b.
> 
>>
>> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
>> ---
>>  fs/nfsd/nfs4state.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 8840206..7f78ff5 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -411,6 +411,8 @@ static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
>>  {
>>  	remove_stid(&dp->dl_stid);
>>  	if (atomic_dec_and_test(&dp->dl_count)) {
>> +		if (dp->dl_file)
>> +			put_nfs4_file(dp->dl_file);
>>  		nfs4_free_stid(deleg_slab, &dp->dl_stid);
>>  		num_delegations--;
>>  	}
>> @@ -450,8 +452,6 @@ static void unhash_stid(struct nfs4_stid *s)
>>  	dp->dl_stid.sc_type = 0;
>>  	nfs4_put_deleg_lease(dp->dl_file);
>>  	spin_unlock(&recall_lock);
>> -	put_nfs4_file(dp->dl_file);
>> -	dp->dl_file = NULL;
>>  }
>>  
>>  
>> -- 
>> 1.8.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
