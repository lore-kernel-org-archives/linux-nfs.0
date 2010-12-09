Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:57775 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603Ab0LIR2W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 12:28:22 -0500
Subject: Re: [Bug 24302] Kernel crashes when repeatedly trying to mount nfs share that is failing
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D011109.7050505@canonical.com>
Date: Thu, 9 Dec 2010 12:27:20 -0500
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>
Message-Id: <2047EA6E-CFE5-436C-BF63-E7FAE77F7C43@oracle.com>
References: <bug-24302-104@https.bugzilla.kernel.org/> <201012081830.oB8IUZ4t027387@demeter2.kernel.org> <1291835010.3067.4.camel@heimdal.trondhjem.org> <3F9D016C-9EDF-4B65-AD77-F225D5F1FA66@oracle.com> <A205A7F2-6E7C-4129-BC3A-D2AE5E38DFE6@oracle.com> <4D00AB9F.3030808@canonical.com> <B1576FB0-9865-429A-8053-673DAEE96F88@oracle.com> <4D011109.7050505@canonical.com>
To: Stefan Bader <stefan.bader@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 9, 2010, at 12:25 PM, Stefan Bader wrote:

> On 12/09/2010 04:23 PM, Chuck Lever wrote:
>> 
>> On Dec 9, 2010, at 5:12 AM, Stefan Bader wrote:
>> 
>>> On 12/09/2010 01:19 AM, Chuck Lever wrote:
>>>> Hi Stefan-
>>>> 
>>>> On Dec 8, 2010, at 3:35 PM, Chuck Lever wrote:
>>>> 
>>>>> 
>>>>> On Dec 8, 2010, at 2:03 PM, Trond Myklebust wrote:
>>>>> 
>>>>>> On Wed, 2010-12-08 at 18:30 +0000, bugzilla-daemon@bugzilla.kernel.org 
>>>>>> wrote:
>>>>>>> https://bugzilla.kernel.org/show_bug.cgi?id=24302
>>>>>>> 
>>>>>>> 
>>>>>>> Andrew Morton <akpm@linux-foundation.org> changed:
>>>>>>> 
>>>>>>> What    |Removed                     |Added 
>>>>>>> ----------------------------------------------------------------------------
>>>>>>> 
>>>>>>> 
>>> Component|Other                       |NFS
>>>>>>> AssignedTo|fs_other@kernel-bugs.osdl.o |trond.myklebust@fys.uio.no |rg
>>>>>>> |
>>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>>>> --- Comment #8 from Andrew Morton <akpm@linux-foundation.org>
>>>>>>> 2010-12-08 18:30:32 --- OK, I reassigned it to NFS.  If that was wrong
>>>>>>> then at least the NFS guys should be able to help point things in the
>>>>>>> right direction.
>>>>>> 
>>>>>> <Switching to email interface. Please do not edit the bugzilla entry 
>>>>>> directly, since that will lose the above Cc information>
>>> 
>>> Missed to read the above, so I have to duplicate things a bit, sorry. Removed
>>> the bugzilla cc, so the report does not get spammed.
>>> 
>>>>>> 
>>>>>> 
>>>>>> Chuck,
>>>>>> 
>>>>>> Stefan appears to be hitting a panic in the nfs_umount() call from 
>>>>>> nfs_walk_authlist(). Can you take a look, please?
>>>>> 
>>>>> Recv'd.  I'll have a look.
>>>> 
>>>> Apologies in advance for the attachment.  There are a few other clean ups
>>>> that can be done, but this seems to be the minimal fix.  Please try this and
>>>> let us know if it addresses your panic.
>>>> 
>>>> 
>>>> 
>>>> 
>>>> 
>>>> 
>>>> The faulty commit went in a while back, so this patch is probably appropriate
>>>> for stable kernels (back to 2.6.31, where this was likely introduced).
>>>> 
>>> 
>>> I can confirm that this was the root cause of the crash. The sha referenced as
>>> the causing commit, got in with a 2.6.32-rc so I added the stable info
>>> accordingly. I also added my tested-by and slightly modified the bug reference
>>> format (Chuck, I hope this is ok).
>> 
>> Looks good to me.  I assume, since Trond still owns the kernel.org bugzilla, that he will close this loop?  Let me know if I need to do anything else.
>> 
> Actually someone spotted that the second array_size should probably use
> mnt_procedures3 instead of mnt_procedures. They happen to be the same size,
> so testing is ok.

Oops.  Copy-n-paste error, I thought I had fixed that.  Good catch.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




