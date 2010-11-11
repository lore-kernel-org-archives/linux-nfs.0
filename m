Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65358 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932074Ab0KKBSN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 20:18:13 -0500
Message-ID: <4CDB4516.1040707@cn.fujitsu.com>
Date: Thu, 11 Nov 2010 09:21:26 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4.1: Make sure nfsd can decode SP4_SSV correctly
 at exchange_id
References: <4CD3B362.8070302@cn.fujitsu.com> <4CD8A64B.20905@cn.fujitsu.com> <20101110193425.GB27237@fieldses.org>
In-Reply-To: <20101110193425.GB27237@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields :
> On Tue, Nov 09, 2010 at 09:39:23AM +0800, Mi Jinlong wrote:
>> According to RFC, the argument of ssv_sp_parms4 is:
>>
>>    struct ssv_sp_parms4 {
>>            state_protect_ops4      ssp_ops;
>>            sec_oid4                ssp_hash_algs<>;
>>            sec_oid4                ssp_encr_algs<>;
>>            uint32_t                ssp_window;
>>            uint32_t                ssp_num_gss_handles;
>>    };
>>
>> If client send a exchange_id with SP4_SSV, server cann't decode
>> the SP4_SSV's ssp_hash_algs and ssp_encr_algs arguments correctly.
>>
>> Because the kernel treat the two arguments as a signal 
>> sec_oid4 struct, but should be a set of sec_oid4 struct.
> 
> That looks correct, thanks.
> 
> (How are you testing this?)

  I use the pynfs41 test site at your git tree. (EID50)

thanks,
Mi Jinlong

> 
> --b.
> 
>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>> ---
>>  fs/nfsd/nfs4xdr.c |   22 +++++++++++++++-------
>>  1 files changed, 15 insertions(+), 7 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index f35a94a..71d7d33 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -1005,7 +1005,7 @@ static __be32
>>  nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
>>  			 struct nfsd4_exchange_id *exid)
>>  {
>> -	int dummy;
>> +	int dummy, tmp;
>>  	DECODE_HEAD;
>>  
>>  	READ_BUF(NFS4_VERIFIER_SIZE);
>> @@ -1053,15 +1053,23 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
>>  
>>  		/* ssp_hash_algs<> */
>>  		READ_BUF(4);
>> -		READ32(dummy);
>> -		READ_BUF(dummy);
>> -		p += XDR_QUADLEN(dummy);
>> +		READ32(tmp);
>> +		while (tmp--) {
>> +			READ_BUF(4);
>> +			READ32(dummy);
>> +			READ_BUF(dummy);
>> +			p += XDR_QUADLEN(dummy);
>> +		}
>>  
>>  		/* ssp_encr_algs<> */
>>  		READ_BUF(4);
>> -		READ32(dummy);
>> -		READ_BUF(dummy);
>> -		p += XDR_QUADLEN(dummy);
>> +		READ32(tmp);
>> +		while (tmp--) {
>> +			READ_BUF(4);
>> +			READ32(dummy);
>> +			READ_BUF(dummy);
>> +			p += XDR_QUADLEN(dummy);
>> +		}
>>  
>>  		/* ssp_window and ssp_num_gss_handles */
>>  		READ_BUF(8);
>> -- 1.7.0.1 
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

-- 
----
Regards
Mi Jinlong

