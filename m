Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51830 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbaKCRHp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2014 12:07:45 -0500
Date: Mon, 3 Nov 2014 12:07:43 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsidmap: keyctl_invalidate kernel compatibility
In-Reply-To: <BBA57534-87D3-4403-A0C6-4E77E8FB1418@oracle.com>
Message-ID: <alpine.LRH.2.11.1411031206560.20279@sh-el6.eng.rdu2.redhat.com>
References: <643db7f6caed9ec25c0067aec85b97190bfbe174.1415026355.git.bcodding@redhat.com> <BBA57534-87D3-4403-A0C6-4E77E8FB1418@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 3 Nov 2014, Chuck Lever wrote:

>
> On Nov 3, 2014, at 9:54 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
>
>> Change the keyctl_invalidate call to use the syscall interface directly so
>> that when building with libkeyutils missing keyctl_invalidate the build succeeds.
>> Attempt to use _invalidate and fall back to _revoke if the current kernel is
>> missing _invalidate.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>> utils/nfsidmap/nfsidmap.c |   15 +++++++++++----
>> 1 files changed, 11 insertions(+), 4 deletions(-)
>>
>> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
>> index e0d31e7..99ae07e 100644
>> --- a/utils/nfsidmap/nfsidmap.c
>> +++ b/utils/nfsidmap/nfsidmap.c
>> @@ -209,10 +209,17 @@ static int key_invalidate(char *keystr, int keymask)
>> 		*(strchr(buf, ' ')) = '\0';
>> 		sscanf(buf, "%x", &key);
>>
>> -		if (keyctl_invalidate(key) < 0) {
>> -			xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
>> -			fclose(fp);
>> -			return 1;
>> +/* older libkeyutils compatibility */
>> +#ifndef KEYCTL_INVALIDATE
>> +#define KEYCTL_INVALIDATE 21      /* invalidate a key */
>> +#endif
>> +		if (keyctl(KEYCTL_INVALIDATE, key) < 0 && errno == EOPNOTSUPP) {
>> +			/* older kernel compatibility attempt: */
>> +			if (keyctl_revoke(key) < 0) {
>> +				xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
>> +				fclose(fp);
>> +				return 1;
>> +			}
>
> Thanks, Ben.
>
> This logic handles and reports errors only from keyctl_revoke().
> Can it be updated to report errors (other than EOPNOTSUPP) from
> either function, display the name of the keyctl function it
> tried to invoke, and close fp and exit appropriately?

Oh.. right.  Of course.

Ben
