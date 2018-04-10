Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:36211 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751611AbeDJUJL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Apr 2018 16:09:11 -0400
Received: by mail-vk0-f46.google.com with SMTP id q198so7823730vke.3
        for <linux-nfs@vger.kernel.org>; Tue, 10 Apr 2018 13:09:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180308170511.GF10782@fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com> <20180220164229.65404-11-kolga@netapp.com>
 <20180308170511.GF10782@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 10 Apr 2018 16:09:09 -0400
Message-ID: <CAN-5tyFZR7nOKks7nA__rLE3p4Dr7uwm7dHyKb_obOn74NbnHw@mail.gmail.com>
Subject: Re: [PATCH v7 10/10] NFSD stop queued async copies on client shutdown
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 8, 2018 at 12:05 PM, J. Bruce Fields <bfields@fieldses.org> wro=
te:
> On Tue, Feb 20, 2018 at 11:42:29AM -0500, Olga Kornievskaia wrote:
>> If client is shutting down and there are still async copies going
>> on, then stop queued async copies.
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  fs/nfsd/nfs4proc.c  | 13 +++++++++++++
>>  fs/nfsd/nfs4state.c |  1 +
>>  fs/nfsd/state.h     |  1 +
>>  3 files changed, 15 insertions(+)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 57d0daa..54039e4 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1096,6 +1096,19 @@ static void nfs4_put_copy(struct nfsd4_copy *copy=
)
>>       kfree(copy);
>>  }
>>
>> +void nfsd4_shutdown_copy(struct nfs4_client *clp)
>> +{
>> +     struct nfsd4_copy *copy;
>> +
>> +     spin_lock(&clp->async_lock);
>> +     list_for_each_entry(copy, &clp->async_copies, copies) {
>> +             set_tsk_thread_flag(copy->copy_task, TIF_SIGPENDING);
>> +             kthread_stop(copy->copy_task);
>> +             nfs4_put_copy(copy);
>
> Those three lines could go in a common helper to be called here and from
> nfsd4_offload_cancel().

Hi Bruce,

I have a question. I=E2=80=99m testing how the code works in
nfsd4_shutdown_copy. I have disabled canceling the copy (just
returning ok) and so then the client can stop its copy and do the
close and then I can issue an unmount. What I see is that the server
returns =E2=80=9Cerr_delay=E2=80=9D until the copy finishes. That=E2=80=99s=
 because in
nfsd4_destroy_clientid() it calls mark_client_expired_locked() which
checks the refcount on the client structure and since copy holds a
reference server returns err_delay. Once the copy finished and
decrements the reference, and nfsd4_destroy_clientid() gets past that
then calling nfsd4_shutdown_copy() doesn=E2=80=99t find any copies.

Should the logic of nfsd4_destroy_clientid() be changed to stop copies
then instead of during destruction of the client structure?

>
> --b.
>
>> +     }
>> +     spin_unlock(&clp->async_lock);
>> +}
>> +
>>  static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
>>  {
>>       struct nfsd4_copy *copy =3D container_of(cb, struct nfsd4_copy, cp=
_cb);
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index bd76bd1..f9f2383 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1965,6 +1965,7 @@ static __be32 mark_client_expired_locked(struct nf=
s4_client *clp)
>>               release_openowner(oo);
>>       }
>>       nfsd4_return_all_client_layouts(clp);
>> +     nfsd4_shutdown_copy(clp);
>>       nfsd4_shutdown_callback(clp);
>>       if (clp->cl_cb_conn.cb_xprt)
>>               svc_xprt_put(clp->cl_cb_conn.cb_xprt);
>> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
>> index 49709d1..131aefa 100644
>> --- a/fs/nfsd/state.h
>> +++ b/fs/nfsd/state.h
>> @@ -646,6 +646,7 @@ extern void nfsd4_init_cb(struct nfsd4_callback *cb,=
 struct nfs4_client *clp,
>>  extern int nfsd4_create_callback_queue(void);
>>  extern void nfsd4_destroy_callback_queue(void);
>>  extern void nfsd4_shutdown_callback(struct nfs4_client *);
>> +extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
>>  extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
>>  extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *n=
ame,
>>                                                       struct nfsd_net *n=
n);
>> --
>> 1.8.3.1
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
