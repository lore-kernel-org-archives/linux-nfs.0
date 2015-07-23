Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34898 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbbGWBJV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 21:09:21 -0400
Received: by pdrg1 with SMTP id g1so147246628pdr.2
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2015 18:09:21 -0700 (PDT)
Message-ID: <55B03EB5.9080207@gmail.com>
Date: Thu, 23 Jul 2015 09:09:09 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 05/14] nfsd: Use check_stateid_generation() for generation
 checking
References: <55A384B1.8030207@gmail.com> <55A38569.8070405@gmail.com> <20150722182228.GA3168@fieldses.org>
In-Reply-To: <20150722182228.GA3168@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/23/2015 02:22, J. Bruce Fields wrote:
> I don't think layout stateid handling is the same as handling of other
> stateid's.  See
> 
> 	https://tools.ietf.org/html/rfc5661#section-12.5.3

Yes,

  "Given the design goal of pNFS to provide parallelism, the layout
   stateid differs from other stateid types in that the client is
   expected to send LAYOUTGET and LAYOUTRETURN operations in parallel."

Please ignore this patch.

thanks,
Kinglong Mee

> 
> I haven't reviewed it in detail yet.
> 
> --b.
> 
> On Mon, Jul 13, 2015 at 05:31:21PM +0800, Kinglong Mee wrote:
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/nfs4layouts.c | 5 ++---
>>  fs/nfsd/nfs4state.c   | 2 +-
>>  fs/nfsd/state.h       | 1 +
>>  3 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
>> index 6904213..5c0f1d6 100644
>> --- a/fs/nfsd/nfs4layouts.c
>> +++ b/fs/nfsd/nfs4layouts.c
>> @@ -263,9 +263,8 @@ nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
>>  			goto out;
>>  	} else {
>>  		ls = container_of(stid, struct nfs4_layout_stateid, ls_stid);
>> -
>> -		status = nfserr_bad_stateid;
>> -		if (stateid->si_generation > stid->sc_stateid.si_generation)
>> +		status = check_stateid_generation(stateid, &stid->sc_stateid, 1);
>> +		if (status)
>>  			goto out_put_stid;
>>  		if (layout_type != ls->ls_layout_type)
>>  			goto out_put_stid;
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 998166d..2edfedc 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -4474,7 +4474,7 @@ static bool stateid_generation_after(stateid_t *a, stateid_t *b)
>>  	return (s32)(a->si_generation - b->si_generation) > 0;
>>  }
>>  
>> -static __be32 check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_session)
>> +__be32 check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_session)
>>  {
>>  	/*
>>  	 * When sessions are used the stateid generation number is ignored
>> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
>> index 4874ce5..18d015d 100644
>> --- a/fs/nfsd/state.h
>> +++ b/fs/nfsd/state.h
>> @@ -589,6 +589,7 @@ extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
>>  __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
>>  		     stateid_t *stateid, unsigned char typemask,
>>  		     struct nfs4_stid **s, struct nfsd_net *nn);
>> +__be32 check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_session);
>>  struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
>>  		struct kmem_cache *slab);
>>  void nfs4_unhash_stid(struct nfs4_stid *s);
>> -- 
>> 2.4.3
> 
