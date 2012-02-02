Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755364Ab2BBNwC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Feb 2012 08:52:02 -0500
Message-ID: <4F2A94FA.30603@netapp.com>
Date: Thu, 02 Feb 2012 08:51:54 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: Boaz Harrosh <bharrosh@panasas.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFS: dont allow minorversion= opt when vers != 4
References: <1328123201-894-1-git-send-email-dros@netapp.com> <4F29C04B.8020703@panasas.com> <BD47F92C-6031-4F3F-A715-8275C7399717@netapp.com>
In-Reply-To: <BD47F92C-6031-4F3F-A715-8275C7399717@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/01/12 18:07, Adamson, Dros wrote:

> On Feb 1, 2012, at 5:44 PM, Boaz Harrosh wrote:
> 
>> On 02/01/2012 09:06 PM, Weston Andros Adamson wrote:
>>> Don't allow invalid 'vers' and 'minorversion' combinations in mount options,
>>> such as "vers=3,minorversion=1".
>>>
>>
>> Just my $0.017 I don't see the point in this. 
>>
>> If vers==3 then minorversion is ignored, just like today.
>> What kind  of extra protection does it buy us?
> 
> No, minorversion is not ignored when vers=3.  


But after mounting, does setting vers=3, minorversion=1 cause any change in NFS v3 behavior?

- Bryan

> 
> Try an invalid (v4) minorversion:
> 
> $ sudo mount -t nfs -o vers=3,minorversion=2 server:/export /mnt 
> mount.nfs: an incorrect mount option was specified
> $ dmesg | tail -1
> [ 1734.758101] NFS: bad mount option value specified: minorversion=2
> 
> I can understand why this was never a priority, but I find it quite confusing when version=3,minorversion=1 succeeds -- I've fat-fingered that more than a few times, started running tests and only later realized my mistake.
> 
>>
>> But maybe it's just me
>>
> 
> I know it's not just me who's been confused by this in the past :)
> 
> -dros
> 
>> Thanks
>> Boaz
>>
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> %d -> %u for printing mnt->version.
>>>
>>> fs/nfs/super.c |    7 +++++++
>>> 1 files changed, 7 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index 8e210b2..b88e023 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -1519,6 +1519,9 @@ static int nfs_parse_mount_options(char *raw,
>>> 	if (!sloppy && invalid_option)
>>> 		return 0;
>>>
>>> +	if (mnt->minorversion && mnt->version != 4)
>>> +		goto out_minorversion_mismatch;
>>> +
>>> 	/*
>>> 	 * verify that any proto=/mountproto= options match the address
>>> 	 * familiies in the addr=/mountaddr= options.
>>> @@ -1552,6 +1555,10 @@ out_invalid_address:
>>> out_invalid_value:
>>> 	printk(KERN_INFO "NFS: bad mount option value specified: %s\n", p);
>>> 	return 0;
>>> +out_minorversion_mismatch:
>>> +	printk(KERN_INFO "NFS: mount option vers=%u does not support "
>>> +			 "minorversion=%u\n", mnt->version, mnt->minorversion);
>>> +	return 0;
>>> out_nomem:
>>> 	printk(KERN_INFO "NFS: not enough memory to parse option\n");
>>> 	return 0;
>>
> 


