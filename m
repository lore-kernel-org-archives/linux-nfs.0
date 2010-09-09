Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:50850 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791Ab0IIR2c convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Sep 2010 13:28:32 -0400
Subject: Re: [PATCH 1/3] mount.nfs: Refactor mount version and protocol autonegotiation
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100907111246.7de7d757@notabene>
Date: Thu, 9 Sep 2010 13:27:38 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <D0DBF3C1-0C80-4C30-8344-39974AD7CBD6@oracle.com>
References: <20100831212006.21061.17002.stgit@matisse.1015granger.net> <20100831212130.21061.10519.stgit@matisse.1015granger.net> <20100907111246.7de7d757@notabene>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 6, 2010, at 9:12 PM, Neil Brown wrote:

> On Tue, 31 Aug 2010 17:21:31 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> The logic that manages negotiating NFS version and protocol settings
>> is getting more complex over time, so let's split this out of
>> nfs_try_mount().
>> 
>> This should make Bruce a little happier, as it eliminates the silent
>> switch case fall through in nfs_try_mount().  And it should help Neil
>> fix some bugs he's found in this logic.
> 
> Hi Chuck,
> thanks for these..
> One question....
> 
> .....
>> +{
>> +	int result;
>> +
>> +	/*
>> +	 * Before 2.6.32, the kernel NFS client didn't support
>> +	 * "-t nfs vers=4" mounts, so NFS version 4 cannot be
>> +	 * included when autonegotiating while running on
>> +	 * those kernels.
>> +	 */
>> +	if (linux_version_code() <= MAKE_VERSION(2, 6, 31))
>> +		goto fall_back;
>> +
>> +	errno = 0;
>> +	result = nfs_try_mount_v4(mi);
>> +	switch (errno) {
> 
> Should we not have e.g.
> 
>   if (result)
>         return result;
> 
> before the switch(errno)??  Typically errno is 'undefined' in no error is
> reported.
> 
> I realise the current code doesn't have that test either, but I still think
> it is wrong not to.

We have

  errno = 0;

just before the nfs_try_mount_v4(mi); call.  This defines the value of errno even if nothing in nfs_try_mount_v4() sets it.

Perhaps that violates Bruce's "too subtle" rule and I should replace it with your suggested post-call check?

> Thanks
> NeilBrown
> 
> 
> 
>> +	case EPROTONOSUPPORT:
>> +		/* A clear indication that the server or our
>> +		 * client does not support NFS version 4. */
>> +		goto fall_back;
>> +	case ENOENT:
>> +		/* Legacy Linux servers don't export an NFS
>> +		 * version 4 pseudoroot. */
>> +		goto fall_back;
>> +	case EPERM:
>> +		/* Linux servers prior to 2.6.25 may return
>> +		 * EPERM when NFS version 4 is not supported. */
>> +		goto fall_back;
>> +	default:
>> +		return result;
>> +	}
>> +
>> +fall_back:
>> +	return nfs_try_mount_v3v2(mi);
>> +}
>> +
>> +/*
>>  * This is a single pass through the fg/bg loop.
>>  *
>>  * Returns TRUE if successful, otherwise FALSE.
>> @@ -758,20 +801,8 @@ static int nfs_try_mount(struct nfsmount_info *mi)
>> 
>> 	switch (mi->version) {
>> 	case 0:
>> -		if (linux_version_code() > MAKE_VERSION(2, 6, 31)) {
>> -			errno = 0;
>> -			result = nfs_try_mount_v4(mi);
>> -			if (errno != EPROTONOSUPPORT) {
>> -				/* 
>> -				 * To deal with legacy Linux servers that don't
>> -				 * automatically export a pseudo root, retry
>> -				 * ENOENT errors using version 3. And for
>> -				 * Linux servers prior to 2.6.25, retry EPERM
>> -				 */
>> -				if (errno != ENOENT && errno != EPERM)
>> -					break;
>> -			}
>> -		}
>> +		result = nfs_autonegotiate(mi);
>> +		break;
>> 	case 2:
>> 	case 3:
>> 		result = nfs_try_mount_v3v2(mi);
> 

-- 
chuck[dot]lever[at]oracle[dot]com




