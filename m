From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 04/44] nfsd41: turn off create session caching
Date: Tue, 16 Jun 2009 21:47:41 -0400
Message-ID: <89c397150906161847v2a051ea7oa3fb6297501f62f2@mail.gmail.com>
References: <1245115163-6931-1-git-send-email-bhalevy@panasas.com>
	 <20090616182704.GC3045@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f214.google.com ([209.85.217.214]:55838 "EHLO
	mail-gx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261AbZFQBrj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2009 21:47:39 -0400
Received: by gxk10 with SMTP id 10so37462gxk.13
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2009 18:47:41 -0700 (PDT)
In-Reply-To: <20090616182704.GC3045@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 2:27 PM, J. Bruce Fields<bfields@fieldses.org> wrote:
> On Tue, Jun 16, 2009 at 04:19:23AM +0300, Benny Halevy wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> In preparation for switching clientid cache strategies.
>> If cstate->slot is not set, nfsdsvc_encode_compoundres will not cache
>> the create session response.
>
> This is a regression.  If you can't find a way to replace the reply
> cache without a temporary regression, a comment here to that affect
> would be helpful.  I guess I can live with this (reluctantly) for code
> in this early a state.

I can put the replacement of the create session replay cache into one
patch and avoid any temporary regressions if that would be helpful.

-->Andy

>
> --b.
>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4state.c |    7 -------
>>  1 files changed, 0 insertions(+), 7 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index c22ec9b..5fdef66 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1344,7 +1344,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>>                    struct nfsd4_create_session *cr_ses)
>>  {
>>       u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
>> -     struct nfsd4_compoundres *resp = rqstp->rq_resp;
>>       struct nfs4_client *conf, *unconf;
>>       struct nfsd4_slot *slot = NULL;
>>       int status = 0;
>> @@ -1360,11 +1359,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>>               if (status == nfserr_replay_cache) {
>>                       dprintk("Got a create_session replay! seqid= %d\n",
>>                               slot->sl_seqid);
>> -                     cstate->slot = slot;
>> -                     cstate->status = status;
>> -                     /* Return the cached reply status */
>> -                     status = nfsd4_replay_cache_entry(resp, NULL);
>> -                     goto out;
>>               } else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
>>                       status = nfserr_seq_misordered;
>>                       dprintk("Sequence misordered!\n");
>> @@ -1413,7 +1407,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>>       cr_ses->seqid = slot->sl_seqid;
>>
>>       slot->sl_inuse = true;
>> -     cstate->slot = slot;
>>       /* Ensure a page is used for the cache */
>>       slot->sl_cache_entry.ce_cachethis = 1;
>>  out:
>> --
>> 1.6.3
>>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
