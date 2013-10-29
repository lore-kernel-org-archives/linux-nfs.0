Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:34015 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab3J2HAT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 03:00:19 -0400
Received: by mail-we0-f174.google.com with SMTP id u56so7652454wes.5
        for <linux-nfs@vger.kernel.org>; Tue, 29 Oct 2013 00:00:18 -0700 (PDT)
Message-ID: <526F5CFF.2080003@primarydata.com>
Date: Tue, 29 Oct 2013 09:00:15 +0200
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: no need to unhash_stid before free
References: <1381730515-18045-1-git-send-email-bhalevy@primarydata.com> <20131028183214.GH31322@fieldses.org>
In-Reply-To: <20131028183214.GH31322@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-28 20:32, J. Bruce Fields wrote:
> On Mon, Oct 14, 2013 at 09:01:55AM +0300, Benny Halevy wrote:
>> idr_remove is about to be called before kmem_cache_free so unhashing it
>> is redundant
> 
> This leaves only two unhash_stid callers, in release_lock_stateid and
> unhash_stid, both called just before destroying the stateid, so perhaps
> we should remove those and unhash_stid?

In my state lock elimination patchset I actually keep using unhash_stid
after refactoring non-blocking unhashing from the blocking release
so I don't think it's worth it to remove the call.
That said, we can still open code it but encapsulating the assignment
in unhash_stid() which the compiler can inline anyway seems cleaner to me.

Benny

> 
> --b.
> 
>>
>> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
>> ---
>>  fs/nfsd/nfs4state.c | 7 ++-----
>>  1 file changed, 2 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 0874998..06984e3 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -668,7 +668,6 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
>>  static void release_open_stateid(struct nfs4_ol_stateid *stp)
>>  {
>>  	unhash_open_stateid(stp);
>> -	unhash_stid(&stp->st_stid);
>>  	free_generic_stateid(stp);
>>  }
>>  
>> @@ -690,7 +689,6 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
>>  	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
>>  
>>  	if (s) {
>> -		unhash_stid(&s->st_stid);
>>  		free_generic_stateid(s);
>>  		oo->oo_last_closed_stid = NULL;
>>  	}
>> @@ -3998,10 +3996,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
>>  
>>  	nfsd4_close_open_stateid(stp);
>>  
>> -	if (cstate->minorversion) {
>> -		unhash_stid(&stp->st_stid);
>> +	if (cstate->minorversion)
>>  		free_generic_stateid(stp);
>> -	} else
>> +	else
>>  		oo->oo_last_closed_stid = stp;
>>  
>>  	if (list_empty(&oo->oo_owner.so_stateids)) {
>> -- 
>> 1.8.3.1
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
