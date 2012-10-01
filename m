Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:55361 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552Ab2JAXMO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2012 19:12:14 -0400
Received: by weyt9 with SMTP id t9so3249068wey.19
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2012 16:12:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FFAAF9@SACEXCMBX04-PRD.hq.netapp.com>
References: <1348866309-2049-1-git-send-email-andros@netapp.com>
	<1348866309-2049-2-git-send-email-andros@netapp.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA908FFAAF9@SACEXCMBX04-PRD.hq.netapp.com>
Date: Mon, 1 Oct 2012 19:12:12 -0400
Message-ID: <CAHVgHyUJ2qLa8zGS72d0cpPtZEf=9U+YN_7G+=WaayDpSimsXA@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv4.0 reclaim reboot state when re-establishing clientid
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 1, 2012 at 6:15 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Fri, 2012-09-28 at 17:05 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> We should always reclaim state when the lease and therefore the clientid
>> is expired.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfs/nfs4state.c |    6 ++++--
>>  1 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index a5331ec..134323a 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1600,8 +1600,8 @@ out:
>>       return nfs4_recovery_handle_error(clp, status);
>>  }
>>
>> -/* Set NFS4CLNT_LEASE_EXPIRED for all v4.0 errors and for recoverable errors
>> - * on EXCHANGE_ID for v4.1
>> +/* Set NFS4CLNT_LEASE_EXPIRED and reclaim reboot state for all v4.0 errors
>> + * and for recoverable errors on EXCHANGE_ID for v4.1
>>   */
>>  static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
>>  {
>> @@ -1647,6 +1647,8 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
>>               return status;
>>       }
>>       set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
>> +     nfs4_state_clear_reclaim_reboot(clp);
>> +     nfs4_state_start_reclaim_reboot(clp);
>
> This is probably correct for NFS4ERR_STALE_CLIENTID, but certainly not
> for NFS4ERR_SEQ_MISORDERED, or NFS4ERR_DELAY...
>


Oops - will resend with fix...

-->Andy

>>       dprintk("%s: handled error %d for server %s\n", __func__, status,
>>                       clp->cl_hostname);
>>       return 0;
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
