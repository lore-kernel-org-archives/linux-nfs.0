Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35587 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752047AbdBMKy1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2017 05:54:27 -0500
Date: Mon, 13 Feb 2017 12:54:22 +0200
From: Hans Liljestrand <ishkamiel@gmail.com>
To: David Windsor <dwindsor@gmail.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        kernel-hardening@lists.openwall.com,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Kees Cook <keescook@chromium.org>,
        "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: Re: [kernel-hardening] Re: [RFC][PATCH] nfsd: add +1 to reference
 counting scheme for struct nfsd4_session
Message-ID: <20170213105422.snaw65btejr3vsdi@ishxps>
References: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
 <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
In-Reply-To: <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 11, 2017 at 01:42:53AM -0500, David Windsor wrote:
><snip>
>
>> Signed-off-by: David Windsor <dwindsor@gmail.com>
>> ---
>>  fs/nfsd/nfs4state.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index a0dee8a..b0f3010 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -196,7 +196,7 @@ static void nfsd4_put_session_locked(struct nfsd4_session *ses)
>>
>>         lockdep_assert_held(&nn->client_lock);
>>
>> -       if (atomic_dec_and_test(&ses->se_ref) && is_session_dead(ses))
>> +       if (!atomic_add_unless(&ses->se_ref, -1, 1) && is_session_des(ses))
>
>This should read:
>if (!atomic_add_unless(&ses->se_ref, -1, 1) && is_session_dead(ses))
>
>>                 free_session(ses);

Hi, 

I'm not sure if I have this correctly; But both before and after the patch 
free_session gets called when se_ref count was 1, shouldn't this have changed 
with the +1 scheme?

Also, since the !atomic_add_unless doesn't actually decrement when at 1, 
doesn't this leave the se_ref as 1 when it's destroyed? The function seems to 
always be locked, so perhaps this doesn't matter, but still seems a bit risky.

Thanks,
-hans

>>         put_client_renew_locked(clp);
>>  }
>> @@ -1645,7 +1645,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
>>         new->se_flags = cses->flags;
>>         new->se_cb_prog = cses->callback_prog;
>>         new->se_cb_sec = cses->cb_sec;
>> -       atomic_set(&new->se_ref, 0);
>> +       atomic_set(&new->se_ref, 1);
>>         idx = hash_sessionid(&new->se_sessionid);
>>         list_add(&new->se_hash, &nn->sessionid_hashtbl[idx]);
>>         spin_lock(&clp->cl_lock);
>> @@ -1792,7 +1792,7 @@ free_client(struct nfs4_client *clp)
>>                 ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
>>                                 se_perclnt);
>>                 list_del(&ses->se_perclnt);
>> -               WARN_ON_ONCE(atomic_read(&ses->se_ref));
>> +               WARN_ON_ONCE((atomic_read(&ses->se_ref) > 1));
>>                 free_session(ses);
>>         }
>>         rpc_destroy_wait_queue(&clp->cl_cb_waitq);
>> --
>> 2.7.4
>>
