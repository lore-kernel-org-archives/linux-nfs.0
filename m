Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:48384 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827Ab3LCCJK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 21:09:10 -0500
Received: by mail-pa0-f50.google.com with SMTP id kl14so2233976pab.9
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 18:09:09 -0800 (PST)
Message-ID: <529D3D3B.7060204@gmail.com>
Date: Tue, 03 Dec 2013 10:08:59 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Add missing recording of back channel attrs in nfsd4_session
References: <2BCCA4EF-9FCC-4320-85E1-AD500467C95D@gmail.com> <20131202165505.GL1960@fieldses.org>
In-Reply-To: <20131202165505.GL1960@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/03/2013 12:55 AM, J. Bruce Fields wrote:
> On Tue, Nov 26, 2013 at 10:25:20PM +0800, Kinglong Mee wrote:
>> commit 5b6feee9608dce7afd2646f457c93e612526d1d8 forgot
>> recording the back channel attrs in nfsd4_session.
>>
>> nfsd just check the back channel attars by check_backchannel_attrs,
>> but do not  record it in nfsd4_session in the latest kernel.
> 
> Whoops.  So the current server is returning random uninitialized data in
> those fields, or all zeros?
> 
> It would be easy enough to write a pynfs test for this, I think.

No, server returns right data for nfsd4_encode_create_session encoding
back-channel attrs from struct nfsd4_create_session, not from nfsd4_session.

Without this patch, se_bchannel in struct nfsd4_session contains data with all zeros.

thanks,
Kinglong Mee

>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/nfs4state.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 105d6fa..1aed9be 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -999,6 +999,8 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
>>  	spin_unlock(&nn->client_lock);
>>  	memcpy(&new->se_fchannel, &cses->fore_channel,
>>  			sizeof(struct nfsd4_channel_attrs));
>> +	memcpy(&new->se_bchannel, &cses->back_channel,
>> +			sizeof(struct nfsd4_channel_attrs));
>>  	if (cses->flags & SESSION4_BACK_CHAN) {
>>  		struct sockaddr *sa = svc_addr(rqstp);
>>  		/*
>> -- 
>> 1.8.1.4
>>
> 

