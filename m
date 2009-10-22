From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 2/2] nfs41: fix race on session reset
Date: Thu, 22 Oct 2009 09:32:33 -0400
Message-ID: <89c397150910220632o5708b8efhb7223541315b4e33@mail.gmail.com>
References: <1256149492-25481-1-git-send-email-andros@netapp.com>
	 <1256149492-25481-2-git-send-email-andros@netapp.com>
	 <1256149492-25481-3-git-send-email-andros@netapp.com>
	 <4AE05C12.7070403@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:62123 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755765AbZJVNcf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Oct 2009 09:32:35 -0400
Received: by ywh40 with SMTP id 40so5430979ywh.33
        for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2009 06:32:40 -0700 (PDT)
In-Reply-To: <4AE05C12.7070403@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 22, 2009 at 9:20 AM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On Oct. 21, 2009, 20:24 +0200, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Do not clear the NFS4CLNT_SESSION_SETUP bit until after the session =
has been
>> reset (a possible EXCHANGE_ID, a DESTROY_SESSION, and a CREATE_SESSI=
ON) to
>> prevent a race with nfs41_setup_sequence assigning a slot on a
>> partially reset session.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> =A0fs/nfs/nfs4proc.c =A0| =A0 =A03 +++
>> =A0fs/nfs/nfs4state.c | =A0 15 +++++++++------
>> =A02 files changed, 12 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index eb245a1..80764e2 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -4788,6 +4788,9 @@ int nfs4_proc_create_session(struct nfs_client=
 *clp, int reset)
>> =A0 =A0 =A0 if (status)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>
>> + =A0 =A0 /* Signal nfs41_setup_sequence that the session is ready f=
or use */
>> + =A0 =A0 clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
>> +
>> =A0 =A0 =A0 ptr =3D (unsigned *)&session->sess_id.data[0];
>> =A0 =A0 =A0 dprintk("%s client>seqid %d sessionid %u:%u:%u:%u\n", __=
func__,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 clp->cl_seqid, ptr[0], ptr[1], ptr[2], p=
tr[3]);
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 1394dfb..09ca30b 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1252,17 +1252,20 @@ static void nfs4_state_manager(struct nfs_cl=
ient *clp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Initialize or reset the session */
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (test_and_clear_bit(NFS4CLNT_SESSION_SE=
TUP, &clp->cl_state)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&& nfs4_has_session(clp)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (test_bit(NFS4CLNT_SESSION_SETUP, &clp-=
>cl_state)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 && nfs4_has_session(clp)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (clp->cl_cons_state =3D=
=3D NFS_CS_SESSION_INITING)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D=
 nfs4_initialize_session(clp);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D=
 nfs4_reset_session(clp);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status=
 =3D=3D -NFS4ERR_STALE_CLIENTID)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status =3D=3D -NFS4ERR=
_STALE_CLIENTID)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* For error case. On succ=
ess the bit is cleared in
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* nfs4_proc_create_sess=
ion */
>
> Why the separation?
> Why not handle both success and error cases here?

We don't clear the bit on NFS4ERR_STALE_CLIENTID because we first need
an EXCHANGE_ID and then session reset and we don't want any rpc's
queued on the slot_tbl_waitq to run. The check for
NFS4ERR_STALE_CLIENTID is in the nfs4_state_manager. Also, all other
cases in the state manager clear the bits used - so I thought it best
to follow suit.

-->Andy

>
> Benny
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(NFS4CLNT_SESSION=
_SETUP, &clp->cl_state);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out=
_error;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* First recover reboot state... */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (test_and_clear_bit(NFS4CLNT_RECLAIM_=
REBOOT, &clp->cl_state)) {
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
