From: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Subject: Re: [pnfs] [PATCH 1/1] nfs41: resolve some race conditions with
	queued SEQUENCE operations when unmounting
Date: Wed, 14 Oct 2009 14:50:32 -0700
Message-ID: <5e24e8930910141450h11e677bbr17ebe3441a8742d8@mail.gmail.com>
References: <1255561029-2925-1-git-send-email-batsakis@netapp.com>
	 <1255555809.6308.34.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexandros Batsakis <batsakis@netapp.com>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:55076 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbZJNWPG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2009 18:15:06 -0400
Received: by pzk26 with SMTP id 26so205807pzk.4
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2009 15:14:30 -0700 (PDT)
In-Reply-To: <1255555809.6308.34.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2009 at 2:30 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Wed, 2009-10-14 at 15:57 -0700, Alexandros Batsakis wrote:
>> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
>> ---
>> =A0fs/nfs/nfs4_fs.h =A0 | =A0 =A01 +
>> =A0fs/nfs/nfs4proc.c =A0| =A0 =A03 +++
>> =A0fs/nfs/nfs4state.c | =A0 11 ++++++++---
>> =A03 files changed, 12 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>> index 6ea07a3..554af98 100644
>> --- a/fs/nfs/nfs4_fs.h
>> +++ b/fs/nfs/nfs4_fs.h
>> @@ -45,6 +45,7 @@ enum nfs4_client_state {
>> =A0 =A0 =A0 NFS4CLNT_RECLAIM_NOGRACE,
>> =A0 =A0 =A0 NFS4CLNT_DELEGRETURN,
>> =A0 =A0 =A0 NFS4CLNT_SESSION_SETUP,
>> + =A0 =A0 NFS4CLNT_SESSION_DESTROY,
>> =A0};
>>
>> =A0/*
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index c321002..9eb21d2 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -359,6 +359,8 @@ static void nfs41_sequence_done(struct nfs_clien=
t *clp,
>> =A0 =A0 =A0 struct nfs4_slot_table *tbl;
>> =A0 =A0 =A0 struct nfs4_slot *slot;
>>
>> + =A0 =A0 if (!nfs4_has_session(clp))
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* sr_status remains 1 if an RPC level error occurred.=
 The server
>> =A0 =A0 =A0 =A0* may or may not have processed the sequence operatio=
n..
>> @@ -4616,6 +4618,7 @@ struct nfs4_session *nfs4_alloc_session(struct=
 nfs_client *clp)
>>
>> =A0void nfs4_destroy_session(struct nfs4_session *session)
>> =A0{
>> + =A0 =A0 set_bit(NFS4CLNT_SESSION_DESTROY, &session->clp->cl_state)=
;
>> =A0 =A0 =A0 nfs4_proc_destroy_session(session);
>> =A0 =A0 =A0 dprintk("%s Destroy backchannel for xprt %p\n",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, session->clp->cl_rpcclient->cl=
_xprt);
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 1394dfb..a509b26 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1253,11 +1253,16 @@ static void nfs4_state_manager(struct nfs_cl=
ient *clp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Initialize or reset the session */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (test_and_clear_bit(NFS4CLNT_SESSION_=
SETUP, &clp->cl_state)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&& nfs4_has_session(clp)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 && nfs4_has_session(clp)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (clp->cl_cons_state =3D=
=3D NFS_CS_SESSION_INITING)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D=
 nfs4_initialize_session(clp);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D=
 nfs4_reset_session(clp);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (test_b=
it(NFS4CLNT_SESSION_DESTROY,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0&clp->cl_state))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 status =3D -EIO;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 status =3D nfs4_reset_session(clp);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (stat=
us =3D=3D -NFS4ERR_STALE_CLIENTID)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 continue;
>
> Wait... Why is all this needed?
>
> AFAICS, nfs_destroy_session() is only called by nfs_free_client() onc=
e
> the very last reference to the nfs_client has been released. Now sinc=
e
> the state manager keeps a reference to the nfs_client all the time wh=
ile
> it is running (see nfs4_run_state_manager()), we _can't_ have a race
> between it and nfs4_destroy_session().
>

This is correct very and in the normal case it is not a problem.
However, the problems start when the server is down/rebooted/etc and
the client tries to umount.
Then, the (SEQUENCE) requests are _already_ queued and when the server
comes up or the request is cancelled (ctl-c), we see these race
conditions:

a) nfs41_sequence_done() called after destroy_session() that leads to
a NULL pointer dereference
b) a BADSESSION reply to a sequence operation triggers a
reset_session() at the same time with destroy_session() (called by
umount) that leads to another NULL pointer dereference.

I can send you the call traces if you need more info. I understand
that these are pretty rare cases, but they shouldn't lead to a crash.

-alexandros

> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
