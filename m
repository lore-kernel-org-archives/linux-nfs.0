Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17196 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330Ab1I3PGB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Sep 2011 11:06:01 -0400
Message-ID: <4E85DAD1.1030507@netapp.com>
Date: Fri, 30 Sep 2011 11:05:53 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 1/3] NFSD: Added fault injection
References: <1317322765-19094-1-git-send-email-bjschuma@netapp.com> <A7558C0C-378A-42E3-AC37-8152C50972DB@oracle.com> <4E84D1B8.20903@netapp.com> <F9CDB8C6-E680-4373-81CD-CA8E8A635F84@oracle.com> <4E85D44C.10309@netapp.com> <1FA193FD-A334-4027-8102-A575012467AC@oracle.com>
In-Reply-To: <1FA193FD-A334-4027-8102-A575012467AC@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/30/2011 10:57 AM, Chuck Lever wrote:
> 
> On Sep 30, 2011, at 10:38 AM, Bryan Schumaker wrote:
> 
>> On 09/30/2011 10:28 AM, Chuck Lever wrote:
>>>
>>> On Sep 29, 2011, at 4:14 PM, Bryan Schumaker wrote:
>>>
>>>> On 09/29/2011 03:06 PM, Chuck Lever wrote:
>>>>>
>>>>> On Sep 29, 2011, at 2:59 PM, bjschuma@netapp.com wrote:
>>>>>
>>>>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>>>>>
>>>> ...
>>>>>> diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
>>>>>> index 9b118ee..69eae75 100644
>>>>>> --- a/fs/nfsd/Makefile
>>>>>> +++ b/fs/nfsd/Makefile
>>>>>> @@ -5,7 +5,8 @@
>>>>>> obj-$(CONFIG_NFSD)	+= nfsd.o
>>>>>>
>>>>>> nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
>>>>>> -			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
>>>>>> +			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o \
>>>>>> +			   fault_inject.o
>>>>>> nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
>>>>>> nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
>>>>>> nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
>>>>>> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
>>>>>> new file mode 100644
>>>>>> index 0000000..2139883
>>>>>> --- /dev/null
>>>>>> +++ b/fs/nfsd/fault_inject.c
>>>>>> @@ -0,0 +1,102 @@
>>>>>> +#ifdef CONFIG_NFSD_FAULT_INJECTION
>>>>>
>>>>> The usual practice is to conditionally compile this source file via a Makefile variable, not by wrapping the whole source file in an ifdef.  You can see examples of this in the Makefile hunk above.
>>>>>
>>>>
>>>> How's this?  I moved the selectively compile bit to the makefile and created a fault_inject.h for the empty init() and cleanup() functions.  I moved the rest of the fault injection function declarations there, too, to keep them all together.
>>>
>>> OK.  How about adding documenting block comments for the new files?  Does NetApp require you to add a copyright notice at the top of new files?
>>
>> I have no idea if I'm required, but I can if it's needed.
> 
> Ask Trond or Beepy.
> 
>>> Also, I wonder if it would be better if you added "default N" for the new CONFIG option.
>>
>> What would trigger the default option?  Right now I control this by writing a number into the debugfs file.  I suppose reading from the file could trigger the default case.
> 
> See below.

Oh!  I get what you mean now.  I thought you meant "n" as in the number of things to delete, and not default the feature to off.  Yeah, I can change that.

> 
>>
>>>
>>>> - Bryan
>>>>
>>>> Fault injection on the NFS server makes it easier to test the client's
>>>> state manager and recovery threads.  Simulating errors on the server is
>>>> easier than finding the right conditions that cause them naturally.
>>>>
>>>> This patch uses debugfs to add a simple framework for fault injection to
>>>> the server.  This framework is a config option, and can be enabled
>>>> through CONFIG_NFSD_FAULT_INJECTION.  Assuming you have debugfs mounted
>>>> to /sys/debug, a set of files will be created in /sys/debug/nfsd/.
>>>> Writing to any of these files will cause the corresponding action and
>>>> write a log entry to dmesg.
>>>>
>>>> Changes in v4:
>>>> - Move fault injection function declarations to a new .h file
>>>> - Use the Makefile to selectively compile fault_injection.c
>>>>
>>>> Changes in v3:
>>>> - Code cleanup and better use of generic functions
>>>> - Allow the user to input the number of state objects to delete
>>>> - Remove "forget_everything()" since forgetting a client is basically
>>>> the same thing
>>>>
>>>> Changes in v2:
>>>> - Replaced "forget all state owners" with "forget all open owners"
>>>> - Include fs/nfsd/fault_inject.c in the patch
>>>>
>>>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>>>> ---
>>>> fs/nfsd/Kconfig        |   10 ++++
>>>> fs/nfsd/Makefile       |    1 +
>>>> fs/nfsd/fault_inject.c |   88 ++++++++++++++++++++++++++++++++++++
>>>> fs/nfsd/fault_inject.h |   22 +++++++++
>>>> fs/nfsd/nfs4state.c    |  115 ++++++++++++++++++++++++++++++++++++++++++++++++
>>>> fs/nfsd/nfsctl.c       |    7 +++
>>>> 6 files changed, 243 insertions(+), 0 deletions(-)
>>>> create mode 100644 fs/nfsd/fault_inject.c
>>>> create mode 100644 fs/nfsd/fault_inject.h
>>>>
>>>> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
>>>> index 10e6366..52fdd1c 100644
>>>> --- a/fs/nfsd/Kconfig
>>>> +++ b/fs/nfsd/Kconfig
>>>> @@ -80,3 +80,13 @@ config NFSD_V4
>>>> 	  available from http://linux-nfs.org/.
>>>>
>>>> 	  If unsure, say N.
>>>> +
>>>> +config NFSD_FAULT_INJECTION
>>>> +	bool "NFS server manual fault injection"
>>>> +	depends on NFSD_V4 && DEBUG_KERNEL
> 
>         default N
> 
>>>> +	help
>>>> +	  This option enables support for manually injectiong faults
>>>> +	  into the NFS server.  This is intended to be used for
>>>> +	  testing error recovery on the NFS client.
>>>> +
>>>> +	  If unsure, say N.
> 
> I'm not sure that would even work.  But the idea is to prevent "make oldconfig" from even asking.  It should just be N unless it's explicitly set via the menu or an architecture config file.
> 

