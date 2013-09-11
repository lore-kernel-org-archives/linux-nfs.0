Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f43.google.com ([74.125.82.43]:57484 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424Ab3IKN13 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Sep 2013 09:27:29 -0400
Received: by mail-wg0-f43.google.com with SMTP id z12so8009572wgg.22
        for <linux-nfs@vger.kernel.org>; Wed, 11 Sep 2013 06:27:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378905228.34823.3.camel@leira.trondhjem.org>
References: <1378853073-13256-1-git-send-email-dros@netapp.com>
 <1378853073-13256-4-git-send-email-dros@netapp.com> <CAFX2Jf=kbrS6byZBFOoZ64-rb9tCvUHDPZqkip3cy5K12FzaqQ@mail.gmail.com>
 <1378905228.34823.3.camel@leira.trondhjem.org>
From: Anna Schumaker <schumaker.anna@gmail.com>
Date: Wed, 11 Sep 2013 09:27:07 -0400
Message-ID: <CAFX2JfnzBqVJKqb1eU7WxwfvKXOAZsf3H0T-fe9buHRNFsTdPQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] NFSv4.1: sp4_mach_cred: no need to ref count creds
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Okay, thanks!  I think I missed that explanation yesterday.

On Wed, Sep 11, 2013 at 9:13 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2013-09-11 at 08:59 -0400, Anna Schumaker wrote:
>> Do we need to do a get_rpccred() after looking up the machine cred in
>> nfs_alloc_client()?  Where does our guaranteed reference come from?
>
> See my comment to Dros' first patchset yesterday. In the case of
> SP4_MACH_CRED, we cannot change the machine credential, since the state
> protection is completely tied to that credential. In fact if you look at
> the current code, we only actually free the cl_machine_cred in
> nfs_free_client().
>
> For that reason, it is safe to assume that it is available for the
> duration of the RPC call. Of course, rpc_task_set_rpc_message() will
> also take a reference, but that too is redundant in this particular
> case.
>
> Cheers
>   Trond
>
>> Anna
>>
>>
>>
>> On Tue, Sep 10, 2013 at 6:44 PM, Weston Andros Adamson
>> <dros@netapp.com> wrote:
>>         The cl_machine_cred doesn't need to be reference counted here
>>         -
>>         a reference is held is for the lifetime of the struct
>>         nfs_client.
>>         Also, no need to put_rpccred the rpc_message.rpc_cred.
>>
>>         Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>         ---
>>          fs/nfs/nfs4_fs.h | 6 +++---
>>          1 file changed, 3 insertions(+), 3 deletions(-)
>>
>>         diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>>         index f520a11..07a8aa9 100644
>>         --- a/fs/nfs/nfs4_fs.h
>>         +++ b/fs/nfs/nfs4_fs.h
>>         @@ -279,10 +279,10 @@ _nfs4_state_protect(struct nfs_client
>>         *clp, unsigned long sp4_mode,
>>                 if (test_bit(sp4_mode, &clp->cl_sp4_flags)) {
>>                         spin_lock(&clp->cl_lock);
>>                         if (clp->cl_machine_cred != NULL)
>>         -                       newcred =
>>         get_rpccred(clp->cl_machine_cred);
>>         +                       /* don't call get_rpccred on the
>>         machine cred -
>>         +                        * a reference will be held for life
>>         of clp */
>>         +                       newcred = clp->cl_machine_cred;
>>                         spin_unlock(&clp->cl_lock);
>>         -               if (msg->rpc_cred)
>>         -                       put_rpccred(msg->rpc_cred);
>>                         msg->rpc_cred = newcred;
>>
>>                         flavor =
>>         clp->cl_rpcclient->cl_auth->au_flavor;
>>         --
>>         1.7.12.4 (Apple Git-37)
>>
>>         --
>>         To unsubscribe from this list: send the line "unsubscribe
>>         linux-nfs" in
>>         the body of a message to majordomo@vger.kernel.org
>>         More majordomo info at
>>          http://vger.kernel.org/majordomo-info.html
>>
>>
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
