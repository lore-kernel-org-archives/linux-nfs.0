Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f180.google.com ([209.85.212.180]:40382 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754039Ab3KEEFS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 23:05:18 -0500
Received: by mail-wi0-f180.google.com with SMTP id ey11so1506605wid.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Nov 2013 20:05:17 -0800 (PST)
Message-ID: <52786E74.8030505@primarydata.com>
Date: Mon, 04 Nov 2013 20:05:08 -0800
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: remove_stid can be incorporated into nfs4_put_delegation
References: <525CE711.1040107@primarydata.com> <1381820280-14120-1-git-send-email-bhalevy@primarydata.com> <20131104224758.GB8828@fieldses.org>
In-Reply-To: <20131104224758.GB8828@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-11-04 14:47, J. Bruce Fields wrote:
> On Tue, Oct 15, 2013 at 09:58:00AM +0300, Benny Halevy wrote:
>> All calls to nfs4_put_delegation are preceded with remove_stid.
> 
> Whoops, no, we missed the nfs4_put_delegation call in
> fs/nfsd/nfs4callback.c.
> 
> Noticed because some pynfs tests triggered idr warnings about freeing
> the same id twice.
> 
> I guess I'll revert.

OK.

Benny

> 
> --b.
> 
>>
>> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
>> ---
>>  fs/nfsd/nfs4state.c | 4 +---
>>  1 file changed, 1 insertion(+), 3 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index b8f3c7e..93160b6 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -410,6 +410,7 @@ static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
>>  void
>>  nfs4_put_delegation(struct nfs4_delegation *dp)
>>  {
>> +	remove_stid(&dp->dl_stid);
>>  	if (atomic_dec_and_test(&dp->dl_count)) {
>>  		nfs4_free_stid(deleg_slab, &dp->dl_stid);
>>  		num_delegations--;
>> @@ -450,14 +451,12 @@ static void unhash_stid(struct nfs4_stid *s)
>>  static void destroy_revoked_delegation(struct nfs4_delegation *dp)
>>  {
>>  	list_del_init(&dp->dl_recall_lru);
>> -	remove_stid(&dp->dl_stid);
>>  	nfs4_put_delegation(dp);
>>  }
>>  
>>  static void destroy_delegation(struct nfs4_delegation *dp)
>>  {
>>  	unhash_delegation(dp);
>> -	remove_stid(&dp->dl_stid);
>>  	nfs4_put_delegation(dp);
>>  }
>>  
>> @@ -3157,7 +3156,6 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
>>  	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
>>  	return;
>>  out_free:
>> -	remove_stid(&dp->dl_stid);
>>  	nfs4_put_delegation(dp);
>>  out_no_deleg:
>>  	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
>> -- 
>> 1.8.3.1
>>
