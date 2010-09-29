Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751907Ab0I2LMP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Sep 2010 07:12:15 -0400
Message-ID: <4CA31F0B.9000507@RedHat.com>
Date: Wed, 29 Sep 2010 07:12:11 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Suresh Jayaraman <sjayaraman@suse.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs(5): document new local_lock option
References: <4C9BA266.1040102@suse.de> <4CA2BCBB.4000008@suse.de> <4CA31E1A.30901@RedHat.com>
In-Reply-To: <4CA31E1A.30901@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/29/2010 07:08 AM, Steve Dickson wrote:
> 
> 
> On 09/29/2010 12:12 AM, Suresh Jayaraman wrote:
>> Steve,
>>
>> I see this patch is missing in the recent release. Do you see any
>> problems with this? (For the record, the local_lock kernel patches are
>> already in Trond nfs-for-2.6.37 tree).
> I didn't added this since the support is not in the current kernels.
> after thinking about it I probably should have since unknown 
>mount
s/mount/rpc.svcgssd/ ;-)

> options are silently ignored... I'll go ahead and commit now it will
> be ready when the .37 kernel hits the streets... 
> 
> I'm sure with, all the changes that when in to the 1.2.3 release, 
> there will be an upcoming 1.2.4 fairly soon... 
> 
> steved.
>>
>> Thanks,
>>
>> On 09/24/2010 12:24 AM, Suresh Jayaraman wrote:
>>> Kernel 2.6.37 would most likely add a new mount option: local_lock.
>>> Document the new option in the nfs(5) man page.
>>>
>>> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
>>> ---
>>>  utils/mount/nfs.man |   44 ++++++++++++++++++++++++++++++++++++++++++++
>>>  1 files changed, 44 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>>> index 55d4b55..d2a4c5f 100644
>>> --- a/utils/mount/nfs.man
>>> +++ b/utils/mount/nfs.man
>>> @@ -717,6 +717,50 @@ If this option is not specified, the NFS client uses READDIRPLUS requests
>>>  on NFS version 3 mounts to read small directories.
>>>  Some applications perform better if the client uses only READDIR requests
>>>  for all directories.
>>> +.TP 1.5i
>>> +.BR local_lock= mechanism
>>> +Specifies whether to use local locking for any or both of the flock and the
>>> +POSIX locking mechanisms.
>>> +.I mechanism
>>> +can be one of
>>> +.BR all ,
>>> +.BR flock ,
>>> +.BR posix ,
>>> +or
>>> +.BR none .
>>> +This option is supported in kernels 2.6.37 and later.
>>> +.IP
>>> +The Linux NFS client provides a way to make locks local. This means, the
>>> +applications can lock files, but such locks provide exclusion only against
>>> +other applications running on the same client. Remote applications are not
>>> +affected by these locks.
>>> +.IP
>>> +If this option is not specified, or if
>>> +.B none
>>> +is specified, the client assumes that the locks are not local.
>>> +.IP
>>> +If
>>> +.BR all
>>> +is specified, the client assumes that both flock and POSIX locks are local.
>>> +.IP
>>> +If
>>> +.BR flock
>>> +is specified, the client assumes that only flock locks are local and uses
>>> +NLM sideband protocol to lock files when POSIX locks are used.
>>> +.IP
>>> +If
>>> +.BR posix
>>> +is specified, the client assumes that POSIX locks are local and uses NLM
>>> +sideband protocol to lock files when flock locks are used.
>>> +.IP
>>> +To support legacy flock behavior similar to that of NFS clients < 2.6.12, use
>>> +'local_lock=flock'. This option is required when exporting NFS mounts via
>>> +Samba as Samba maps Windows share mode locks as flock. Since NFS clients >
>>> +2.6.12 implement flock by emulating POSIX locks, this will result in
>>> +conflicting locks.
>>> +.IP
>>> +NOTE: When used together, the 'local_lock' mount option will be overridden
>>> +by 'nolock'/'lock' mount option.
>>>  .SS "Options for version 4 only"
>>>  Use these options, along with the options in the first subsection above,
>>>  for NFSv4 only. They will be ignored with older versions.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
