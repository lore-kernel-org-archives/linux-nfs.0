Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:62352 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755023AbaEHTsv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 May 2014 15:48:51 -0400
Received: by mail-vc0-f176.google.com with SMTP id lg15so3948982vcb.35
        for <linux-nfs@vger.kernel.org>; Thu, 08 May 2014 12:48:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140507195823.GA9710@fieldses.org>
References: <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
	<20140507195823.GA9710@fieldses.org>
Date: Thu, 8 May 2014 15:48:50 -0400
Message-ID: <CAHQdGtRuvH_onduKexgsvgQqYdhSX6bOK+aXmuUzLsDhV769Qg@mail.gmail.com>
Subject: Re: [PATCH 37/70] NFSd: nfs4_preprocess_seqid_op should only set
 *stpp on success
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 7, 2014 at 3:58 PM, Bruce Fields <bfields@fieldses.org> wrote:
> Patch-sequencing nit: I'm guessing this wasn't actually a problem until
> previous patches added sequenceid reference counting, turning this case
> into a reference leak.
>
> Therefore to avoid a temporary regression we should probably make this
> change before introducing the reference counting rather than after.

No, there should be no regression. This patch is a cleanup in
preparation for the introduction of reference counting.

> --b.
>
> On Fri, Apr 18, 2014 at 02:44:31PM -0400, Trond Myklebust wrote:
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfsd/nfs4state.c | 10 +++++++---
>>  1 file changed, 7 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index b9d6da652fb1..03a3f51d2828 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -4068,6 +4068,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
>>  {
>>       __be32 status;
>>       struct nfs4_stid *s;
>> +     struct nfs4_ol_stateid *stp = NULL;
>>
>>       dprintk("NFSD: %s: seqid=%d stateid = " STATEID_FMT "\n", __func__,
>>               seqid, STATEID_VAL(stateid));
>> @@ -4077,10 +4078,13 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
>>                                     cstate->minorversion, nn);
>>       if (status)
>>               return status;
>> -     *stpp = openlockstateid(s);
>> -     nfsd4_cstate_assign_replay(cstate, (*stpp)->st_stateowner);
>> +     stp = openlockstateid(s);
>> +     nfsd4_cstate_assign_replay(cstate, stp->st_stateowner);
>>
>> -     return nfs4_seqid_op_checks(cstate, stateid, seqid, *stpp);
>> +     status = nfs4_seqid_op_checks(cstate, stateid, seqid, stp);
>> +     if (!status)
>> +             *stpp = stp;
>> +     return status;
>>  }
>>
>>  static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
>> --
>> 1.9.0
>>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
