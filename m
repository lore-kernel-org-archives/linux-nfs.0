From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 2/2] nfs41: fix race on session reset
Date: Thu, 22 Oct 2009 10:14:49 -0400
Message-ID: <89c397150910220714jae5e335qa8313a994e440660@mail.gmail.com>
References: <1256149492-25481-1-git-send-email-andros@netapp.com>
	 <1256149492-25481-2-git-send-email-andros@netapp.com>
	 <1256149492-25481-3-git-send-email-andros@netapp.com>
	 <4AE05C12.7070403@panasas.com>
	 <89c397150910220632o5708b8efhb7223541315b4e33@mail.gmail.com>
	 <4AE0626B.4090504@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:59966 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755078AbZJVOOp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Oct 2009 10:14:45 -0400
Received: by ywh40 with SMTP id 40so5472982ywh.33
        for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2009 07:14:49 -0700 (PDT)
In-Reply-To: <4AE0626B.4090504@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 22, 2009 at 9:47 AM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On Oct. 22, 2009, 15:32 +0200, "William A. (Andy) Adamson" <androsada=
mson@gmail.com> wrote:
>> On Thu, Oct 22, 2009 at 9:20 AM, Benny Halevy <bhalevy@panasas.com> =
wrote:
>>> On Oct. 21, 2009, 20:24 +0200, andros@netapp.com wrote:
>>>> From: Andy Adamson <andros@netapp.com>
>>>>
>>>> Do not clear the NFS4CLNT_SESSION_SETUP bit until after the sessio=
n has been
>>>> reset (a possible EXCHANGE_ID, a DESTROY_SESSION, and a CREATE_SES=
SION) to
>>>> prevent a race with nfs41_setup_sequence assigning a slot on a
>>>> partially reset session.
>>>>
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> ---
>>>> =A0fs/nfs/nfs4proc.c =A0| =A0 =A03 +++
>>>> =A0fs/nfs/nfs4state.c | =A0 15 +++++++++------
>>>> =A02 files changed, 12 insertions(+), 6 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>> index eb245a1..80764e2 100644
>>>> --- a/fs/nfs/nfs4proc.c
>>>> +++ b/fs/nfs/nfs4proc.c
>>>> @@ -4788,6 +4788,9 @@ int nfs4_proc_create_session(struct nfs_clie=
nt *clp, int reset)
>>>> =A0 =A0 =A0 if (status)
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>>>
>>>> + =A0 =A0 /* Signal nfs41_setup_sequence that the session is ready=
 for use */
>>>> + =A0 =A0 clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
>>>> +
>>>> =A0 =A0 =A0 ptr =3D (unsigned *)&session->sess_id.data[0];
>>>> =A0 =A0 =A0 dprintk("%s client>seqid %d sessionid %u:%u:%u:%u\n", =
__func__,
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 clp->cl_seqid, ptr[0], ptr[1], ptr[2],=
 ptr[3]);
>>>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>>>> index 1394dfb..09ca30b 100644
>>>> --- a/fs/nfs/nfs4state.c
>>>> +++ b/fs/nfs/nfs4state.c
>>>> @@ -1252,17 +1252,20 @@ static void nfs4_state_manager(struct nfs_=
client *clp)
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 contin=
ue;
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Initialize or reset the session */
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 if (test_and_clear_bit(NFS4CLNT_SESSION_=
SETUP, &clp->cl_state)
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&& nfs4_has_session(clp)) {
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 if (test_bit(NFS4CLNT_SESSION_SETUP, &cl=
p->cl_state)
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 && nfs4_has_session(clp)) {
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (clp->cl_cons_state=
 =3D=3D NFS_CS_SESSION_INITING)
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status=
 =3D nfs4_initialize_session(clp);
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status=
 =3D nfs4_reset_session(clp);
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status) {
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (stat=
us =3D=3D -NFS4ERR_STALE_CLIENTID)
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 continue;
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status =3D=3D -NFS4E=
RR_STALE_CLIENTID)
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue=
;
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* For error case. On su=
ccess the bit is cleared in
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* nfs4_proc_create_se=
ssion */
>>> Why the separation?
>>> Why not handle both success and error cases here?
>>
>> We don't clear the bit on NFS4ERR_STALE_CLIENTID because we first ne=
ed
>> an EXCHANGE_ID and then session reset and we don't want any rpc's
>> queued on the slot_tbl_waitq to run. The check for
>> NFS4ERR_STALE_CLIENTID is in the nfs4_state_manager. Also, all other
>> cases in the state manager clear the bits used - so I thought it bes=
t
>> to follow suit.
>
> I agree, so why clear the NFS4CLNT_SESSION_SETUP bit on success
> in nfs4_proc_create_session()

so that nfs4_proc_get_lease_time can use the newly created session.

> Also, nfs4_proc_create_session() clears NFS4CLNT_LEASE_EXPIRED
> which is test_and_cleared by the state manager...

True and harmless.

-->Andy

>
> Benny
>
>>
>> -->Andy
>>
>>> Benny
>>>
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(NFS4CLNT_SESSI=
ON_SETUP, &clp->cl_state);
>>>> +
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status)
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto o=
ut_error;
>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* First recover reboot state... */
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (test_and_clear_bit(NFS4CLNT_RECLAI=
M_REBOOT, &clp->cl_state)) {
>>> _______________________________________________
>>> pNFS mailing list
>>> pNFS@linux-nfs.org
>>> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>>>
>
