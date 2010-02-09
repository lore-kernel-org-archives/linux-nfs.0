From: Andy Adamson <andros@netapp.com>
Subject: Re: [pnfs] [PATCH 2/6] pnfsd: fix NFS4ERR_BADIOMODE in layoutget
Date: Tue, 9 Feb 2010 13:57:32 -0500
Message-ID: <0B8CC342-6972-41A3-ACD0-380762D12346@netapp.com>
References: <1265737357-9405-1-git-send-email-andros@netapp.com>	<1265737357-9405-2-git-send-email-andros@netapp.com> <1265737357-9405-3-git-send-email-andros@netapp.com> <4B71A360.3090302@panasas.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22269 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751169Ab0BIS5i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 13:57:38 -0500
In-Reply-To: <4B71A360.3090302@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 9, 2010, at 1:03 PM, Benny Halevy wrote:

> Thanks!
>
> I'm committing everything but patch 6/6 for now.
> Please check again the !CONFIG_PNFSD case.
> I don't see any problem.

OK - Thanks

-->Andy

>
> Benny
>
> On Feb. 09, 2010, 19:42 +0200, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> If an invalid iomode, or an iomode of LAYOUTIOMODE4_ANY is  
>> specified, the
>> metadata server MUST return NFS4ERR_BADIOMODE.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfsd/nfs4proc.c |   11 ++---------
>> 1 files changed, 2 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 769628f..575e1b6 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1114,21 +1114,14 @@ nfsd4_layoutget(struct svc_rqst *rqstp,
>> 	if (status)
>> 		goto out;
>>
>> -	status = nfserr_inval;
>> +	status = nfserr_badiomode;
>> 	if (lgp->lg_seg.iomode != IOMODE_READ &&
>> -	    lgp->lg_seg.iomode != IOMODE_RW &&
>> -	    lgp->lg_seg.iomode != IOMODE_ANY) {
>> +	    lgp->lg_seg.iomode != IOMODE_RW) {
>> 		dprintk("pNFS %s: invalid iomode %d\n", __func__,
>> 			lgp->lg_seg.iomode);
>> 		goto out;
>> 	}
>>
>> -	status = nfserr_badiomode;
>> -	if (lgp->lg_seg.iomode == IOMODE_ANY) {
>> -		dprintk("pNFS %s: IOMODE_ANY is not allowed\n", __func__);
>> -		goto out;
>> -	}
>> -
>> 	/* Set up arguments so layout can be retrieved at encode time */
>> 	lgp->lg_fhp = current_fh;
>> 	copy_clientid((clientid_t *)&lgp->lg_seg.clientid, cstate->session);

