Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58046 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964923AbcKJUSZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Nov 2016 15:18:25 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Anna Schumaker" <Anna.Schumaker@Netapp.com>
Cc: "Trond Myklebust" <trondmy@primarydata.com>,
        "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>,
        "Oleg Drokin" <green@linuxhacker.ru>
Subject: Re: [PATCH v7 13/31] NFSv4.1: Ensure we always run TEST/FREE_STATEID
 on locks
Date: Thu, 10 Nov 2016 15:18:21 -0500
Message-ID: <BDCCD810-781F-4DD6-91E8-279A2C3377EF@redhat.com>
In-Reply-To: <D4F8C627-7DDD-45FF-900E-253F4FB3F47B@redhat.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
 <599EE56B-46DD-411B-805D-11C2FB5E30A4@redhat.com>
 <34B1D68A-1A1C-4B59-A19E-467D48F7A9D0@redhat.com>
 <F1712484-1131-418A-98F0-272A4A1BAE59@redhat.com>
 <AB669741-1EC9-4C08-86A8-479755398679@redhat.com>
 <6ABCDB9B-997E-49C1-9363-D59AF9BEC0E9@primarydata.com>
 <B41EEA6E-B168-4DE3-AC73-F4270287EF0D@redhat.com>
 <806bf204-eb35-5a3a-30fa-612bf22fb09a@Netapp.com>
 <D4F8C627-7DDD-45FF-900E-253F4FB3F47B@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 10 Nov 2016, at 10:58, Benjamin Coddington wrote:

> Hi Anna,
>
> On 10 Nov 2016, at 10:01, Anna Schumaker wrote:
>> Do you have an estimate for when this patch will be ready?  I want to 
>> include it in my next bugfix pull request for 4.9.
>
> I haven't posted because I am still trying to get to the bottom of 
> another
> problem where the client gets stuck in a loop sending the same stateid 
> over
> and over on NFS4ERR_OLD_STATEID.  I want to make sure this problem 
> isn't
> caused by this fix -- which I don't think it is, but I'd rather make 
> sure.
> If I don't make any progress on this problem by the end of today, I'll 
> post
> what I have.
>
> Read on if interested in this new problem:
>
> It looks like racing opens with the same openowner can be returned out 
> of
> order by the server, so the client sees stateid seqid of 2 before 1.  
> Then a
> LOCK sent with seqid 1 is endlessly retried if sent while doing 
> recovery.
>
> It's hard to tell if I was able to capture all the moving parts to 
> describe
> this problem, though.  As it takes a very long time for me to 
> reproduce, and
> the packet captures were dropping frames.  I'm working on manually
> reproducing it now.

Anna,

I haven't gotten to the bottom of it, and so I'm not confident it isn't 
a
problem created by the fix I've been testing, which is:

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e809498..2aa9d86 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2564,12 +2564,15 @@ static void 
nfs41_check_delegation_stateid(struct
nfs4_state *state)
  static int nfs41_check_expired_locks(struct nfs4_state *state)
  {
         int status, ret = NFS_OK;
-       struct nfs4_lock_state *lsp;
+       struct nfs4_lock_state *lsp, *tmp;
         struct nfs_server *server = NFS_SERVER(state->inode);

         if (!test_bit(LK_STATE_IN_USE, &state->flags))
                 goto out;
-       list_for_each_entry(lsp, &state->lock_states, ls_locks) {
+       spin_lock(&state->state_lock);
+       list_for_each_entry_safe(lsp, tmp, &state->lock_states, 
ls_locks) {
+               atomic_inc(&lsp->ls_count);
+               spin_unlock(&state->state_lock);
                 if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
                         struct rpc_cred *cred =
lsp->ls_state->owner->so_cred;

@@ -2588,7 +2591,10 @@ static int nfs41_check_expired_locks(struct
nfs4_state *state)
                                 break;
                         }
                 }
-       };
+               nfs4_put_lock_state(lsp);
+               spin_lock(&state->state_lock);
+       }
+       spin_unlock(&state->state_lock);
  out:
         return ret;
  }

http://people.redhat.com/bcodding/old_stateid_loop is tshark output of 
my
only good wirecapture of the problem.  Without this patch, generic/089
crashes long before this problem is reproduced, so I am stuck figuring 
it
out, I'm afraid.  Don't wait on my account.

I plan on trying a bit more to reproduce tomorrow, and if I cannot, I'll
write about it under separate cover.

Ben
