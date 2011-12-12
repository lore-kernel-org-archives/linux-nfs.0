Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35762 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965Ab1LLU7p convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 15:59:45 -0500
Received: by yenm11 with SMTP id m11so4143130yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 12:59:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EE62402.6050008@tonian.com>
References: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
	<1323621708-25138-6-git-send-email-tigran.mkrtchyan@desy.de>
	<4EE62402.6050008@tonian.com>
Date: Mon, 12 Dec 2011 21:59:37 +0100
Message-ID: <CAFpJMDrgUfVRFQJ_wKzyRTn3-HQ=Yi4+w0b53AP-Rw3LxYwX9Q@mail.gmail.com>
Subject: Re: [PATH v3 5/5] nfsd41: use pinter to current stateid to avoid
 extra copy
From: Tiramisu Mokka <kofemann@googlemail.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <kofemann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 12, 2011 at 16:55, Benny Halevy <bhalevy@tonian.com> wrote:
> On 2011-12-11 18:41, Tigran Mkrtchyan wrote:
>> From: Tigran Mkrtchyan <kofemann@gmail.com>
>>
>>
>> Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
>> ---
>>  fs/nfsd/nfs4proc.c  |    6 +-----
>>  fs/nfsd/nfs4state.c |    7 +++----
>>  fs/nfsd/xdr4.h      |    3 +--
>>  3 files changed, 5 insertions(+), 11 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index f2f7dfa..b7d1a7b 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1126,10 +1126,7 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
>>  static void
>>  nfsd4_clear_currentstateid(struct nfsd4_compound_state *cstate)
>>  {
>> -     if (cstate->has_stateid) {
>> -             memset(&cstate->current_stateid, 0, sizeof(stateid_t));
>> -             cstate->has_stateid = false;
>> -     }
>> +     cstate->current_stateid = NULL;
>>  }
>>  /*
>>   * COMPOUND call.
>> @@ -1244,7 +1241,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>>               if (!op->status) {
>>                       if (opdesc->op_flags & PROVIDES_CURRENT_STATEID) {
>>                               opdesc->op_set_currentstateid(cstate, &op->u);
>> -                             cstate->has_stateid = true;
>>                       }
>>
>>                       if (opdesc->op_flags & CLEARS_CURRENT_STATEID)
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index d7b8f25..be77cd3 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -4553,16 +4553,15 @@ nfs4_state_shutdown(void)
>>  static void
>>  get_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
>>  {
>> -     if (cstate->has_stateid && CURRENT_STATEID(stateid))
>> -             memcpy(stateid, &cstate->current_stateid, sizeof(stateid_t));
>> +     if (cstate->current_stateid && CURRENT_STATEID(stateid))
>> +             memcpy(stateid, cstate->current_stateid, sizeof(stateid_t));
>>  }
>>
>>  static void
>>  put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
>>  {
>>       if (cstate->minorversion) {
>> -             memcpy(&cstate->current_stateid, stateid, sizeof(stateid_t));
>> -             cstate->has_stateid = true;
>> +             cstate->current_stateid = stateid;
>>       }
>>  }
>>
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index b8435d20..0ad0846 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -54,8 +54,7 @@ struct nfsd4_compound_state {
>>       size_t                  iovlen;
>>       u32                     minorversion;
>>       u32                     status;
>> -     stateid_t               current_stateid;
>> -     bool    has_stateid;
>> +     stateid_t       *current_stateid;
>
> Certainly looks neat.  I'm all for squashing this part of the patchset,
> or just all of it...
>
> Better be defined as const stateid_t * so its contents would be read only
> for its consumers.

sounds good. Thanks.

Tigran.
>
> Benny
>
>>  };
>>
>>  static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
