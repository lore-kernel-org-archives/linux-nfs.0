Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34271 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbbFSAti (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 20:49:38 -0400
Received: by pabvl15 with SMTP id vl15so26404594pab.1
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 17:49:38 -0700 (PDT)
Message-ID: <55836719.8050806@gmail.com>
Date: Fri, 19 Jun 2015 08:49:29 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: Re: [PATCH] nfsd: Prints a suitable length of filehandle
References: <55826C74.8020703@gmail.com> <20150618213550.GB21903@fieldses.org>
In-Reply-To: <20150618213550.GB21903@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/19/2015 5:35 AM, J. Bruce Fields wrote:
> On Thu, Jun 18, 2015 at 03:00:04PM +0800, Kinglong Mee wrote:
>> With nfsd_debug on, fh_verify prints a fixed length of filehandle as,
>> nfsd: fh_verify(8: 00010001 00000000 00000000 00000000 00000000 00000000)
>> nfsd: fh_verify(28: 00070001 001c0002 00000000 041f9334 9b432a4c 835d4c95)
>>
>> This patch lets nfsd prints a suitable length of filehandle as, 
>> nfsd: fh_verify(8: 00010001 00000000)
>> nfsd: fh_verify(28: 00070001 001c0002 00000000 041f9334 9b432a4c 835d4c95 8cbea40f)
>>
>> Also, use snprintf insteads sprintf.
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/nfsfh.c | 18 ++++++++----------
>>  1 file changed, 8 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
>> index 350041a..dd6a5c1 100644
>> --- a/fs/nfsd/nfsfh.c
>> +++ b/fs/nfsd/nfsfh.c
>> @@ -650,16 +650,14 @@ fh_put(struct svc_fh *fhp)
>>  char * SVCFH_fmt(struct svc_fh *fhp)
>>  {
>>  	struct knfsd_fh *fh = &fhp->fh_handle;
>> -
>> -	static char buf[80];
>> -	sprintf(buf, "%d: %08x %08x %08x %08x %08x %08x",
>> -		fh->fh_size,
>> -		fh->fh_base.fh_pad[0],
>> -		fh->fh_base.fh_pad[1],
>> -		fh->fh_base.fh_pad[2],
>> -		fh->fh_base.fh_pad[3],
>> -		fh->fh_base.fh_pad[4],
>> -		fh->fh_base.fh_pad[5]);
>> +	/* 9 * NFS4_FHSIZE / 4 = 288 for fh_pad, 4 for fh_size, 1 for '\0' */
>> +	static char buf[293];
> 
> So that buffer can be shared by multiple users without any locking.
> 
> That's from the preexisting code, not your fault.  Also, I don't know
> whether to care about an unlikely race in debugging code.

I think we should not care it.
We cannot know the caller how to use it, printk directly or save to an pointer.
Otherwise let the caller supporting the buffer? that sounds bad.

> 
> The only risk aside from corruption of the output might be if the race
> could leave the string temporarily non-null-terminated.  I think that's
> possible?  In which case that could be prevented by making sure buf is
> initialized to zeroes and is at least one byte longer than the following
> code will ever write.

Yes, It's possible.
Static variable will be initialized to all zero default.
So, define a longer buffer is enough.

For that, I define a buffer with length is 293.

The max fh_size is NFS4_FHSIZE (128), as max length of
decimal string with a ':' is 4.

The max fh_pad length should be
9 (%08x and a ' ') * NFS4_FHSIZE / 4 = 288.

At last, 1 for '\0'

thanks,
Kinglong Mee

> 
> --b.
> 
>> +	int pos = 0, i = 0;
>> +
>> +	pos = snprintf(buf, sizeof(buf), "%d:", fh->fh_size);
>> +	for (i = 0; i < fh->fh_size / sizeof(__u32); i++)
>> +		pos += snprintf(buf + pos, sizeof(buf) - pos,
>> +				" %08x", fh->fh_base.fh_pad[i]);
>>  	return buf;
>>  }
>>  
>> -- 
>> 2.4.3
> 
