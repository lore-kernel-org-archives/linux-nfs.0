Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38816 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754553AbdJQUo3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 16:44:29 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: Prevent the reuse of a closed stateid
Date: Tue, 17 Oct 2017 16:44:27 -0400
Message-ID: <D1F7A030-765C-41BF-B516-44E72961A3AE@redhat.com>
In-Reply-To: <1508267486.4747.27.camel@redhat.com>
References: <2087b4cab6c695a7df01c1135f1773c9b762f0b0.1508248427.git.bcodding@redhat.com>
 <1508267486.4747.27.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 17 Oct 2017, at 15:11, Jeff Layton wrote:

> On Tue, 2017-10-17 at 09:55 -0400, Benjamin Coddington wrote:
>> While running generic/089 on NFSv4.1, the following on-the-wire 
>> exchange
>> occurs:
>>
>> Client                  Server
>> ----------              ----------
>> OPEN (owner A)  ->
>>                     <-  OPEN response: state A1
>> CLOSE (state A1)->
>> OPEN (owner A)  ->
>>                     <-  CLOSE response: state A2
>>                     <-  OPEN response: state A3
>> LOCK (state A3) ->
>>                     <-  LOCK response: NFS4_BAD_STATEID
>>
>> The server should not be returning state A3 in response to the second 
>> OPEN
>> after processing the CLOSE and sending back state A2.  The problem is 
>> that
>> nfsd4_process_open2() is able to find an existing open state just 
>> after
>> nfsd4_close() has incremented the state's sequence number but before
>> calling unhash_ol_stateid().
>>
>> Fix this by using the state's sc_type field to identify closed state, 
>> and
>> protect the update of that field with st_mutex.  
>> nfsd4_find_existing_open()
>> will return with the st_mutex held, so that the state will not 
>> transition
>> between being looked up and then updated in nfsd4_process_open2().
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>>  fs/nfsd/nfs4state.c | 29 +++++++++++++++++++----------
>>  1 file changed, 19 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 0c04f81aa63b..17473a092d01 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -3503,11 +3503,12 @@ static const struct 
>> nfs4_stateowner_operations openowner_ops = {
>>  static struct nfs4_ol_stateid *
>>  nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open 
>> *open)
>>  {
>> -	struct nfs4_ol_stateid *local, *ret = NULL;
>> +	struct nfs4_ol_stateid *local, *ret;
>>  	struct nfs4_openowner *oo = open->op_openowner;
>>
>> -	lockdep_assert_held(&fp->fi_lock);
>> -
>> +retry:
>> +	ret = NULL;
>> +	spin_lock(&fp->fi_lock);
>>  	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
>>  		/* ignore lock owners */
>>  		if (local->st_stateowner->so_is_open_owner == 0)
>> @@ -3518,6 +3519,18 @@ nfsd4_find_existing_open(struct nfs4_file *fp, 
>> struct nfsd4_open *open)
>>  			break;
>>  		}
>>  	}
>> +	spin_unlock(&fp->fi_lock);
>> +
>> +	/* Did we race with CLOSE? */
>> +	if (ret) {
>> +		mutex_lock(&ret->st_mutex);
>> +		if (ret->st_stid.sc_type != NFS4_OPEN_STID) {
>> +			mutex_unlock(&ret->st_mutex);
>> +			nfs4_put_stid(&ret->st_stid);
>> +			goto retry;
>> +		}
>> +	}
>> +
>>  	return ret;
>>  }
>>
>> @@ -3566,7 +3579,6 @@ init_open_stateid(struct nfs4_file *fp, struct 
>> nfsd4_open *open)
>>  	mutex_lock(&stp->st_mutex);
>>
>>  	spin_lock(&oo->oo_owner.so_client->cl_lock);
>> -	spin_lock(&fp->fi_lock);
>>
>>  	retstp = nfsd4_find_existing_open(fp, open);
>>  	if (retstp)
>> @@ -3583,13 +3595,13 @@ init_open_stateid(struct nfs4_file *fp, 
>> struct nfsd4_open *open)
>>  	stp->st_deny_bmap = 0;
>>  	stp->st_openstp = NULL;
>>  	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
>> +	spin_lock(&fp->fi_lock);
>>  	list_add(&stp->st_perfile, &fp->fi_stateids);
>> +	spin_unlock(&fp->fi_lock);
>>
>
> Another potential problem above. I don't think it's be possible with
> v4.0, but I think it could happen with v4.1+:
>
> Could we end up with racing opens, such that two different nfsds 
> search
> for an existing open and not find one? Then, they both end up here and
> insert two different stateids for the same openowner+file.
>
> That's prevented now because we do it all under the same fi_lock, but
> that won't be the case here.

Yes, that's definitely a problem, and its reminded me why I kept 
dropping
fi_lock - you can't take the st_mutex while holding it..  This is a 
tangly
bit of locking in here..  I'll see what I can come up with.

Ben
