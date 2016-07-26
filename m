Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36419 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbcGZQSY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2016 12:18:24 -0400
Received: by mail-io0-f195.google.com with SMTP id y34so2337550ioi.3
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2016 09:18:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BEA34F37-97D9-49F1-B554-CED9AB2098FC@netapp.com>
References: <1468955980-8675-1-git-send-email-trond.myklebust@primarydata.com> <BEA34F37-97D9-49F1-B554-CED9AB2098FC@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 26 Jul 2016 12:18:22 -0400
Message-ID: <CAN-5tyGpcs5EFCEhE9ShdGyCtMLpKUtC9i8yB1YeVzDpO0PsGw@mail.gmail.com>
Subject: Re: [PATCH] NFSv4: Allow retry of operations that used a returned
 delegation stateid
To: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 20, 2016 at 10:28 AM, Kornievskaia, Olga
<Olga.Kornievskaia@netapp.com> wrote:
>
>> On Jul 19, 2016, at 3:19 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>
>> Fix up nfs4_do_handle_exception() so that it can check if the operation
>> that received the NFS4ERR_BAD_STATEID was using a defunct delegation.
>> Apply that to the case of SETATTR, which will currently return EIO
>> in some cases where this happens.
>>
>> Reported-by: Olga Kornievskaia <kolga@netapp.com>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> fs/nfs/nfs4_fs.h  |  1 +
>> fs/nfs/nfs4proc.c | 79 ++++++++++++++++++++++++++++++++-----------------------
>> 2 files changed, 47 insertions(+), 33 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>> index 768456fa1b17..4be567a54958 100644
>> --- a/fs/nfs/nfs4_fs.h
>> +++ b/fs/nfs/nfs4_fs.h
>> @@ -185,6 +185,7 @@ struct nfs4_state {
>> struct nfs4_exception {
>>       struct nfs4_state *state;
>>       struct inode *inode;
>> +     nfs4_stateid *stateid;
>>       long timeout;
>>       unsigned char delay : 1,
>>                     recovering : 1,
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 6191b7e46913..519368b98762 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -363,6 +363,7 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
>> {
>>       struct nfs_client *clp = server->nfs_client;
>>       struct nfs4_state *state = exception->state;
>> +     const nfs4_stateid *stateid = exception->stateid;
>>       struct inode *inode = exception->inode;
>>       int ret = errorcode;
>>
>> @@ -376,9 +377,18 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
>>               case -NFS4ERR_DELEG_REVOKED:
>>               case -NFS4ERR_ADMIN_REVOKED:
>>               case -NFS4ERR_BAD_STATEID:
>> -                     if (inode && nfs_async_inode_return_delegation(inode,
>> -                                             NULL) == 0)
>> -                             goto wait_on_recovery;
>> +                     if (inode) {
>> +                             int err;
>> +
>> +                             err = nfs_async_inode_return_delegation(inode,
>> +                                             stateid);
>> +                             if (err == 0)
>> +                                     goto wait_on_recovery;
>> +                             if (stateid != NULL && stateid->type == NFS4_DELEGATION_STATEID_TYPE) {
>> +                                     exception->retry = 1;
>> +                                     break;
>> +                             }
>> +                     }
>>                       if (state == NULL)
>>                               break;
>>                       ret = nfs4_schedule_stateid_recovery(server, state);
>> @@ -2669,28 +2679,17 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
>>       return res;
>> }
>>
>> -static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>> -                         struct nfs_fattr *fattr, struct iattr *sattr,
>> -                         struct nfs4_state *state, struct nfs4_label *ilabel,
>> -                         struct nfs4_label *olabel)
>> +static int _nfs4_do_setattr(struct inode *inode,
>> +                         struct nfs_setattrargs *arg,
>> +                         struct nfs_setattrres *res,
>> +                         struct rpc_cred *cred,
>> +                         struct nfs4_state *state)
>> {
>>       struct nfs_server *server = NFS_SERVER(inode);
>> -        struct nfs_setattrargs  arg = {
>> -                .fh             = NFS_FH(inode),
>> -                .iap            = sattr,
>> -             .server         = server,
>> -             .bitmask = server->attr_bitmask,
>> -             .label          = ilabel,
>> -        };
>> -        struct nfs_setattrres  res = {
>> -             .fattr          = fattr,
>> -             .label          = olabel,
>> -             .server         = server,
>> -        };
>>         struct rpc_message msg = {
>>               .rpc_proc       = &nfs4_procedures[NFSPROC4_CLNT_SETATTR],
>> -             .rpc_argp       = &arg,
>> -             .rpc_resp       = &res,
>> +             .rpc_argp       = arg,
>> +             .rpc_resp       = res,
>>               .rpc_cred       = cred,
>>         };
>>       struct rpc_cred *delegation_cred = NULL;
>> @@ -2699,17 +2698,13 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>>       bool truncate;
>>       int status;
>>
>> -     arg.bitmask = nfs4_bitmask(server, ilabel);
>> -     if (ilabel)
>> -             arg.bitmask = nfs4_bitmask(server, olabel);
>> -
>> -     nfs_fattr_init(fattr);
>> +     nfs_fattr_init(res->fattr);
>>
>>       /* Servers should only apply open mode checks for file size changes */
>> -     truncate = (sattr->ia_valid & ATTR_SIZE) ? true : false;
>> +     truncate = (arg->iap->ia_valid & ATTR_SIZE) ? true : false;
>>       fmode = truncate ? FMODE_WRITE : FMODE_READ;
>>
>> -     if (nfs4_copy_delegation_stateid(inode, fmode, &arg.stateid, &delegation_cred)) {
>> +     if (nfs4_copy_delegation_stateid(inode, fmode, &arg->stateid, &delegation_cred)) {
>>               /* Use that stateid */
>>       } else if (truncate && state != NULL) {
>>               struct nfs_lockowner lockowner = {
>> @@ -2719,19 +2714,19 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>>               if (!nfs4_valid_open_stateid(state))
>>                       return -EBADF;
>>               if (nfs4_select_rw_stateid(state, FMODE_WRITE, &lockowner,
>> -                             &arg.stateid, &delegation_cred) == -EIO)
>> +                             &arg->stateid, &delegation_cred) == -EIO)
>>                       return -EBADF;
>>       } else
>> -             nfs4_stateid_copy(&arg.stateid, &zero_stateid);
>> +             nfs4_stateid_copy(&arg->stateid, &zero_stateid);
>>       if (delegation_cred)
>>               msg.rpc_cred = delegation_cred;
>>
>> -     status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
>> +     status = nfs4_call_sync(server->client, server, &msg, &arg->seq_args, &res->seq_res, 1);
>>
>>       put_rpccred(delegation_cred);

Steve D is reporting a kernel oops because there is no "if
(delegation_cred)" check here?


>>       if (status == 0 && state != NULL)
>>               renew_lease(server, timestamp);
>> -     trace_nfs4_setattr(inode, &arg.stateid, status);
>> +     trace_nfs4_setattr(inode, &arg->stateid, status);
>>       return status;
>> }
>>
>> @@ -2741,13 +2736,31 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>>                          struct nfs4_label *olabel)
>> {
>>       struct nfs_server *server = NFS_SERVER(inode);
>> +        struct nfs_setattrargs  arg = {
>> +                .fh             = NFS_FH(inode),
>> +                .iap            = sattr,
>> +             .server         = server,
>> +             .bitmask = server->attr_bitmask,
>> +             .label          = ilabel,
>> +        };
>> +        struct nfs_setattrres  res = {
>> +             .fattr          = fattr,
>> +             .label          = olabel,
>> +             .server         = server,
>> +        };
>>       struct nfs4_exception exception = {
>>               .state = state,
>>               .inode = inode,
>> +             .stateid = &arg.stateid,
>>       };
>>       int err;
>> +
>> +     arg.bitmask = nfs4_bitmask(server, ilabel);
>> +     if (ilabel)
>> +             arg.bitmask = nfs4_bitmask(server, olabel);
>> +
>>       do {
>> -             err = _nfs4_do_setattr(inode, cred, fattr, sattr, state, ilabel, olabel);
>> +             err = _nfs4_do_setattr(inode, &arg, &res, cred, state);
>>               switch (err) {
>>               case -NFS4ERR_OPENMODE:
>>                       if (!(sattr->ia_valid & ATTR_SIZE)) {
>> --
>> 2.7.4
>>
>
> Thanks Trond. That works.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
