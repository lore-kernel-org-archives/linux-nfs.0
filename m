Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53843 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813Ab1G1S17 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 14:27:59 -0400
Received: by yxi11 with SMTP id 11so1717390yxi.19
        for <linux-nfs@vger.kernel.org>; Thu, 28 Jul 2011 11:27:59 -0700 (PDT)
Message-ID: <4E31AA29.4060308@tonian.com>
Date: Thu, 28 Jul 2011 14:27:53 -0400
From: Benny Halevy <bhalevy@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v3 01/25] pnfs: GETDEVICELIST
References: <1311792048-12551-1-git-send-email-rees@umich.edu>	 <1311792048-12551-2-git-send-email-rees@umich.edu> <1311795219.25645.9.camel@lade.trondhjem.org>
In-Reply-To: <1311795219.25645.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-07-27 15:33, Trond Myklebust wrote:
> On Wed, 2011-07-27 at 14:40 -0400, Jim Rees wrote: 
>> From: Andy Adamson <andros@netapp.com>

...

>> @@ -6902,6 +7029,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
>>  	PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
>>  	PROC(RECLAIM_COMPLETE,	enc_reclaim_complete,	dec_reclaim_complete),
>>  	PROC(GETDEVICEINFO,	enc_getdeviceinfo,	dec_getdeviceinfo),
>> +	PROC(GETDEVICELIST,	enc_getdevicelist,	dec_getdevicelist),
> 
> This needs to go at the end of the list of procedures in order to work
> correctly with nfsstat.
> 

FWIW, what matters is the value of NFSPROC4_CLNT_GETDEVICELIST
rather than the order of instantiation of the PROC() macro.
It is defined in end of the respective enum in include/linux/nfs4.h.

Benny

>> 	PROC(LAYOUTGET,		enc_layoutget,		dec_layoutget),
>>  	PROC(LAYOUTCOMMIT,	enc_layoutcommit,	dec_layoutcommit),
>>  	PROC(LAYOUTRETURN,	enc_layoutreturn,	dec_layoutreturn),
> 
> 
