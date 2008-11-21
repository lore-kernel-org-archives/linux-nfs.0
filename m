From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs-utils, umount -l, and unmount requests
Date: Fri, 21 Nov 2008 12:43:06 -0500
Message-ID: <656A1B3E-1002-4F63-B256-7A394A5A05AD@oracle.com>
References: <E1L3ZKo-0005DO-74@mendel.bio.caltech.edu>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: David Mathog <mathog-7GExONQZ6ZKVc3sceRu5cw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:17507 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbYKURna (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Nov 2008 12:43:30 -0500
In-Reply-To: <E1L3ZKo-0005DO-74-Mlb+9xX7RBA8OKIjkCRLjtKIQNXEaThN@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 21, 2008, at Nov 21, 2008, 11:58 AM, David Mathog wrote:
>>>> Removing the first "!lazy &&" resolved my immediate problem.
>>
>> Can you explain further what your "immediate problem" was?
>
> It was the typical hall of mirrors:
>
> 1. upgrade NFS clients Mandriva 2007.1 -> Mandriva 2008.1
> 2. change in log files on server when client reboots - no "unmount
> request" messages logged.  Otherwise client shutdown seemed normal.

I'm trying to understand why that is a problem.  The only issue here  
is that "showmount" against the server will display clients that may  
be no longer mounting its exports.  Otherwise, operationally there is  
really no difference.

MNT_UMNT is advisory.  It is not required, and proper server operation  
does not depend on it.

> 3. tracked that to the /etc/rc.d/init.d/netfs script, which came  
> down to
> a "umount -f -l", where the behavior of -l had changed between  
> releases.
> 4. tracked the -l behavior through a change in umount (actually two)
> such that in the current version the umount.nfs function is entirely
> dependent on the external program, whereas in the former version it
> would do it itself if that external program was not found.
> 5. tracked the -l behavior to the !lazy line in nfsumount.c which was
> mentioned in the first post in this thread.
> 6. removing the "!lazy &&" restored the previous logging behavior by
> the client on shutdown.
>
>> To clarify that, "-l" is used in cases where there are still
>> outstanding NFS RPCs in the kernel for that mount point, but they
>> can't complete because the server isn't available.  Thus the mount
>> point appears busy, and won't umount.  "umount -l" is used here to
>> prevent the system shutdown from hanging.
>>
>> When there may be outstanding NFS requests, the client really
>> shouldn't send the MNT_UMNT.  In general, though, MNT_UMNT is  
>> entirely
>> advisory, and the client shouldn't wait for it to complete.
>
> That's what I'm getting at.  But rather than trying to send it, and
> doing so in such a way that it won't lock up if the server is down, it
> sends nothing.  This changes the behavior of a normal shutdown as seen
> from the server side.

The client shouldn't send MNT_UMNT if it thinks the local file system  
wasn't actually unmounted.  With "umount -l" the kernel doesn't finish  
unmounting until all outstanding requests are complete.  Since that's  
all in the background with "-l", the umount command exits long before  
that, so it can't know whether to send MNT_UMNT or not.

In the normal case (ie "-l" was not specified) the kernel unmounts the  
NFS file system, then the system call returns and reports success or  
failure.  The umount command can then assess whether to send the  
MNT_UMNT call.

>> One of the changes I made in my IPv6 patches is to shorten the  
>> timeout
>> on that clnt_call().  We could even go so far as to make MNT_UMNT
>> entirely asynchronous and not wait for the reply.
>
> That sounds good to me.  If the client makes a "reasonable effort" to
> send the "unmount request" to the server, so that under normal working
> conditions the server will be notified, that should be sufficient.

Except when the umount.nfs command can't tell if the kernel has  
actually unmounted the file system or not.

> One thing that bothers me though are these two situations:
>
> dd if=/dev/zero of=/mountpoint/datafile count=1000000 bs=512
> umount -f -l /mountpoint
>
> and
>
> dd if=/dev/zero of=/mountpoint/datafile count=1000000 bs=512 &
> umount -f -l /mountpoint
>
> What happens to the data being written to datafile, does it make it to
> the server, assuming the server is up and working normally?  The  
> client
> mounted /mountpoint with bg,hard,intr,rw.

I'm not exactly sure how this would work, especially with the presence  
of "-f".  The exact behavior of these flags has changed over time.

But the client should wait for all outstanding I/O to complete and for  
applications to close all files before the file system is actually  
unmounted.  "Hard" will cause the client to retry these requests  
forever.  It may even be the case that the kernel removes that file  
system from the system's file namespace to prevent other applications  
from opening files there.

This is why "umount -l" is probably reasonable during shutdown, but  
perhaps not for normal operation.  During shutdown, any applications  
left running will be killed by the shutdown script anyway.  My opinion  
though is that the shutdown script should try a normal umount first,  
then if it retries, use "umount -l" as a last resort so the rest of  
shutdown processing can continue in an orderly fashion.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
