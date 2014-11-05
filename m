Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f51.google.com ([74.125.82.51]:42858 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299AbaKEOx1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 09:53:27 -0500
Received: by mail-wg0-f51.google.com with SMTP id l18so1110230wgh.10
        for <linux-nfs@vger.kernel.org>; Wed, 05 Nov 2014 06:53:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <545A3916.1050906@Netapp.com>
References: <1415144188-17193-1-git-send-email-trond.myklebust@primarydata.com>
	<1415144188-17193-2-git-send-email-trond.myklebust@primarydata.com>
	<545A3916.1050906@Netapp.com>
Date: Wed, 5 Nov 2014 09:53:26 -0500
Message-ID: <CAHQdGtTCswxntjqdq1=CbEvexFR4RCSotQUUFru9JJR2fCHVrw@mail.gmail.com>
Subject: Re: [PATCH 2/3] NFSv4: Ensure that we call FREE_STATEID when NFSv4.x
 stateids are revoked
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 5, 2014 at 9:49 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Hey Trond,
>
> On 11/04/2014 06:36 PM, Trond Myklebust wrote:
>> NFSv4.x (x>0) requires us to call TEST_STATEID+FREE_STATEID if a stateid is
>> revoked. We will currently fail to do this if the stateid is a delegation.
>>
>> http://lkml.kernel.org/r/CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfs/nfs4proc.c | 8 --------
>>  1 file changed, 8 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index d8f352d8c75f..6cf49af3092d 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -370,11 +370,6 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
>>               case -NFS4ERR_DELEG_REVOKED:
>>               case -NFS4ERR_ADMIN_REVOKED:
>>               case -NFS4ERR_BAD_STATEID:
>> -                     if (inode != NULL && nfs4_have_delegation(inode, FMODE_READ)) {
>> -                             nfs_remove_bad_delegation(inode);
>> -                             exception->retry = 1;
>> -                             break;
>> -                     }
>>                       if (state == NULL)
>>                               break;
>>                       ret = nfs4_schedule_stateid_recovery(server, state);
>> @@ -4849,9 +4844,6 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
>>               case -NFS4ERR_DELEG_REVOKED:
>>               case -NFS4ERR_ADMIN_REVOKED:
>>               case -NFS4ERR_BAD_STATEID:
>> -                     if (state == NULL)
>> -                             break;
>> -                     nfs_remove_bad_delegation(state->inode);
>
> Does filelayout_async_handle_error() need to be updated in the same way?  They are the only remaining caller of nfs_remove_bad_delegation().
>

Oops. Yes, that would be correct.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
