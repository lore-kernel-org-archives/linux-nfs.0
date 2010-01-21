From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 2/2] nfs41: clear NFS4CLNT_RECALL_SLOT bit on session
	reset
Date: Thu, 21 Jan 2010 14:47:29 -0500
Message-ID: <89c397151001211147taee2c21pabb4ed222e581f8f@mail.gmail.com>
References: <1264101557-6619-1-git-send-email-andros@netapp.com>
	 <1264101557-6619-2-git-send-email-andros@netapp.com>
	 <1264102975.3721.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:63078 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab0AUTr3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jan 2010 14:47:29 -0500
Received: by yxe17 with SMTP id 17so343318yxe.33
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jan 2010 11:47:29 -0800 (PST)
In-Reply-To: <1264102975.3721.9.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 21, 2010 at 2:42 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2010-01-21 at 14:19 -0500, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> =A0fs/nfs/nfs4state.c | =A0 =A07 +++++--
>> =A01 files changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 069dcb3..c7f2944 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1291,9 +1291,12 @@ static int nfs4_reset_session(struct nfs_clie=
nt *clp)
>>
>> =A0 =A0 =A0 memset(clp->cl_session->sess_id.data, 0, NFS4_MAX_SESSIO=
NID_LEN);
>> =A0 =A0 =A0 status =3D nfs4_proc_create_session(clp);
>> - =A0 =A0 if (status)
>> + =A0 =A0 if (status) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D nfs4_recovery_handle_error(cl=
p, status);
>> -
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 }
>> + =A0 =A0 /* create_session negotiated new slot table */
>> + =A0 =A0 clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state);
>> =A0out:
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* Let the state manager reestablish state
>
> Errm.... Looking at nfs4_reset_session, wouldn't it make sense to mov=
e
> that 'out:' label down one line, so that we can get rid of that test =
for
> 'status =3D=3D 0'?

yes indeed it would.

-->Andy

>
> Trond
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
