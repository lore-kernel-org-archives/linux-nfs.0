From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 07/44] nfsd41: create_session check replay first
Date: Tue, 16 Jun 2009 21:15:32 -0400
Message-ID: <89c397150906161815v6136e000t338f4fce10ceff23@mail.gmail.com>
References: <1245115172-7030-1-git-send-email-bhalevy@panasas.com>
	 <20090616204734.GE3045@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:5903 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762157AbZFQBYX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2009 21:24:23 -0400
Received: by yw-out-2324.google.com with SMTP id 5so7591ywb.1
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2009 18:24:25 -0700 (PDT)
In-Reply-To: <20090616204734.GE3045@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 4:47 PM, J. Bruce Fields<bfields@fieldses.org> wrote:
> On Tue, Jun 16, 2009 at 04:19:32AM +0300, Benny Halevy wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Replay processing needs to preceed other error processing.
>
> Why?
>

Section 18.36.4. (CREATE_SESSION implementation section) states the
ordering of clientid confirmation processing as
1) client id record lookup
2) sequence id processing
3) client id confirmation

rpc cred processing is done in #3.

->Andy

> --b.
>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4state.c |   12 ++++++------
>>  1 files changed, 6 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index bfc808b..5aef525 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1378,12 +1378,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>>               }
>>               conf->cl_slot.sl_seqid++;
>>       } else if (unconf) {
>> -             if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
>> -                 (ip_addr != unconf->cl_addr)) {
>> -                     status = nfserr_clid_inuse;
>> -                     goto out_cache;
>> -             }
>> -
>>               slot = &unconf->cl_slot;
>>               status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid, 0);
>>               if (status) {
>> @@ -1392,6 +1386,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>>                       goto out;
>>               }
>>
>> +             if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
>> +                 (ip_addr != unconf->cl_addr)) {
>> +                     status = nfserr_clid_inuse;
>> +                     goto out_cache;
>> +             }
>> +
>>               slot->sl_seqid++; /* from 0 to 1 */
>>               move_to_confirmed(unconf);
>>
>> --
>> 1.6.3
>>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
