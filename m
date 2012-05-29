Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:19009 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab2E2QUt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2012 12:20:49 -0400
Subject: Re: ls stalls
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FC4CA16.8080606@fhcrc.org>
Date: Tue, 29 May 2012 12:20:40 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <170E7BB0-7BBB-49A3-A444-EE8CFE98A9EB@oracle.com>
References: <4FB43655.5040907@fhcrc.org> <4FB4397A.6060104@fhcrc.org> <C7DE94F7-9A05-43C1-81EF-10136AE3394E@oracle.com> <4FB4F932.8060104@fhcrc.org> <4FC4CA16.8080606@fhcrc.org>
To: Stuart Kendrick <skendric@fhcrc.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 29, 2012, at 9:07 AM, Stuart Kendrick wrote:

>>> My starting guess is that there is some task on that client that has dirtied the pages of one of the files in the directory you are trying to list.
> A GETATTR is required to flush outstanding writes to a file so the
> server can provide size and mtime attributes that reflect the last most
> recent write to that file.
>>> 
>>> Possible work-arounds: You can reduce the dirty_ratio setting on the client to force it to starting flushing outstanding writes sooner, you can change the writing applications to use synchronous writes (or flush manually), or you can alter your "ls" command so that it doesn't require a GETATTR for each file.
>>> 
> 
> OK, I think I understand that if I've dirtied the pages on a file and
> then issue a stat against it, that the NFS Client will stall my stat
> until it flushes cache.
> 
> And I'm focused on the work-around of:  "You can reduce the dirty_ratio
> setting ..."
> 
> (a) Does the stat /trigger/ a cache flush?  Or does the stat have to
> wait for the usual mechanisms to initiate a flush?

stat(2) invokes the VFS ->getattr method, which is nfs_getattr() for NFS.  nfs_getattr() initiates the flush before sending the GETATTR operation.

> (b) How granular is this process?  Will the NFS Client issue my stat
> (GETATTR) once all the dirty pages relevant to my particular file are
> flushed (but other pages are still being written)?  Or does the NFS
> Client wait until pdflush has entirely emptied cache before proceeding
> with the stat?

The nfs_getattr() function flushes dirty pages for just that file.

nfs_getattr() should cause other writers to wait for the GETATTR to complete; otherwise the GETATTR can be starved.  I'm not sure I see a mechanism like that in 3.4.

> (c) When cache hits dirty_ratio (or dirty_bytes), I believe the kernel
> blocks /all/ writers until it has /emptied/ cache (and flushing a big
> cache to slow storage can take a while) ... am I correct?

Not sure.  You may want to try dirty_background_ratio instead, as that kicks off background flushing, but writers may continue.

> (d) If my load is dominated by large writes over NFS, does cache buy me
> anything?  Seems to me that the dominant benefit of cache is elevatoring
> ... the block structure of storage accessible via NFS is opaque ...
> thus, there's nothing write cache can do to increase the performance of
> the write ... it may as well hand off the blocks in any old order to the
> NFS server and let the storage's cache worry about sequencing the blocks.

Caching is mostly of benefit for readers.

However, delaying small writes has the benefit of allowing a client to coalesce small application write requests into fewer large on-the-wire requests.  It can also be of benefit if an application is overwriting the same part of a file many times, or if it writes then truncates.

Honestly, I've always regarded the aggressive write caching behavior of the Linux NFS client as a performance bug.  The problem is that write flushing is driven almost entirely by the VM in modern Linux kernels, and there isn't a way to adjust specific flushing behavior for a specific file system implementation (hence the use of system-wide tunables as a workaround).

> ==> Seems to me that shrinking dirty_xxx to something really low ...
> like 100K ... would:
> (1) maximize 'stat' performance during heavy writes
> (2) leave NFS write performance unaffected
> 
> but I can tell that I'm missing something here (because when I try it,
> interactive performance, i.e. 'ls -l', tanks).  What am I not understanding?

That's a very broad question.  Try diagnosing the specific problem in your environment, and do try out dirty_background_ratio.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




