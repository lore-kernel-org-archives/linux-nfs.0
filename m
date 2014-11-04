Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:26898 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbaKDUpG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2014 15:45:06 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2] nfsidmap: keyctl_invalidate kernel compatibility
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <54592B0E.5050201@RedHat.com>
Date: Tue, 4 Nov 2014 15:44:56 -0500
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <46A4BDBA-C8B6-47CB-BA19-4D459944EA01@oracle.com>
References: <eee96450255a3407517dd1ed4ce9991ba9f2dbd1.1415034378.git.bcodding@redhat.com> <54592B0E.5050201@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 4, 2014, at 2:37 PM, Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 11/03/2014 12:12 PM, Benjamin Coddington wrote:
>> Change the keyctl_invalidate call to use the syscall interface directly so
>> that when building with libkeyutils missing keyctl_invalidate the build succeeds.
>> Attempt to use _invalidate and fall back to _revoke if the current kernel is
>> missing _invalidate.
>> 
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> Committed... 
> 
> This does get by the nfsidmap compile error when 
> compiling on RHEL6, but not the ones in nfsdcltrack/sqlite.c
> (http://ur1.ca/ioyfs)
> 
> Chuck, how are you getting around them?

Short answer: I’m not.

The nfsdcltrack build fails after nfsidmap is built. I just
installed the nfsidmap binary for testing, and ignored the
rest of upstream nfs-utils.

Do you want me to look into this, or should Jeff do it?

> steved.
> 
>> ---
>> utils/nfsidmap/nfsidmap.c |   21 +++++++++++++++++----
>> 1 files changed, 17 insertions(+), 4 deletions(-)
>> 
>> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
>> index e0d31e7..96149cc 100644
>> --- a/utils/nfsidmap/nfsidmap.c
>> +++ b/utils/nfsidmap/nfsidmap.c
>> @@ -209,10 +209,23 @@ static int key_invalidate(char *keystr, int keymask)
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
>> +		if (keyctl(KEYCTL_INVALIDATE, key) < 0) {
>> +			if (errno != EOPNOTSUPP) {
>> +				xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
>> +				fclose(fp);
>> +				return 1;
>> +			} else {
>> +				/* older kernel compatibility attempt: */
>> +				if (keyctl_revoke(key) < 0) {
>> +					xlog_err("keyctl_revoke(0x%x) failed: %m", key);
>> +					fclose(fp);
>> +					return 1;
>> +				}
>> +			}
>> 		}
>> 
>> 		keymask &= ~mask;
>> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



