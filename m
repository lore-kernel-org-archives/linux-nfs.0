From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs-utils, umount -l, and unmount requests
Date: Fri, 21 Nov 2008 09:59:02 -0500
Message-ID: <B9AA2381-5F9F-4E48-A520-C96F6B755E0D@oracle.com>
References: <E1L2wsc-0004Rs-2I@mendel.bio.caltech.edu> <492696AD.8040905@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>,
	David Mathog <mathog-7GExONQZ6ZKVc3sceRu5cw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:23505 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734AbYKUO7Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Nov 2008 09:59:24 -0500
In-Reply-To: <492696AD.8040905-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 21, 2008, at 6:08 AM, Steve Dickson wrote:
> David Mathog wrote:
>>
>> 	if (mc) {
>> 		if (!lazy && strcmp(mc->m.mnt_type, "nfs4") != 0)
>> 			/* We ignore the error from do_nfs_umount23.
>> 			 * If the actual umount succeeds (in del_mtab),
>> 			 * we don't want to signal an error, as that
>> 			 * could cause /sbin/mount to retry!
>> 			 */
>> 			do_nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
>> 		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
>> 	} else if (*spec != '/') {
>> 		if (!lazy)
>> 			ret = do_nfs_umount23(spec, "tcp,v3");
>> 	} else
>> 		ret = del_mtab(NULL, spec);
>> 	return ret;
>>
>> Removing the first "!lazy &&" resolved my immediate problem.

Can you explain further what your "immediate problem" was?

>> What I
>> don't understand is why it, and the latter "!lazy", were there in
>> the first place.
> To quote from the umount(8) man page:
>
>       -l     Lazy unmount. Detach the filesystem from the  
> filesystem  hierar-
>
>              chy now, and cleanup all references to the filesystem  
> as soon as
>
>              it is not busy anymore.  (Requires kernel 2.4.11 or  
> later.)
>
> Which means in an NFS context that no RPC calls (i.e. call to the  
> server)
> can be made that could possibility hang
>
>
>> The do_nfs_umount23() routine seems to be relatively
>> harmless, it either sends the message or it doesn't, but either way  
>> it
>> doesn't seem to do anything to the mount information on the local  
>> node.
>> So why is it not run if "-l" (lazy) is set?
> Take a closer look... nfs_call_umount() makes a clnt_call() which
> would hang if the server is down, which is the reason its not called.
>
> I hope this helps....

To clarify that, "-l" is used in cases where there are still  
outstanding NFS RPCs in the kernel for that mount point, but they  
can't complete because the server isn't available.  Thus the mount  
point appears busy, and won't umount.  "umount -l" is used here to  
prevent the system shutdown from hanging.

When there may be outstanding NFS requests, the client really  
shouldn't send the MNT_UMNT.  In general, though, MNT_UMNT is entirely  
advisory, and the client shouldn't wait for it to complete.  The  
server maintains a list of clients that have mounted each export, but  
that list isn't used for anything.  So, it shouldn't matter whether  
the MNT_UMNT is sent.

One of the changes I made in my IPv6 patches is to shorten the timeout  
on that clnt_call().  We could even go so far as to make MNT_UMNT  
entirely asynchronous and not wait for the reply.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
