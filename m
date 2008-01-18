From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] enhanced ESTALE error handling
Date: Fri, 18 Jan 2008 12:17:25 -0500
Message-ID: <451AC300-674E-4DBE-869F-08A9184051B3@oracle.com>
References: <4790C756.2040704@redhat.com> <63F84201-9D38-4588-B237-A15138E94C5A@oracle.com> <4790D9F3.2070503@redhat.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:55818 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758780AbYARRSw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2008 12:18:52 -0500
In-Reply-To: <4790D9F3.2070503@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 18, 2008, at 11:55 AM, Peter Staubach wrote:
> Chuck Lever wrote:
>> Hi Peter-
>>
>> On Jan 18, 2008, at 10:35 AM, Peter Staubach wrote:
>>> Hi.
>>>
>>> Here is a patch set which modifies the system to enhance the
>>> ESTALE error handling for system calls which take pathnames
>>> as arguments.
>>
>> The VFS already handles ESTALE.
>>
>> If a pathname resolution encounters an ESTALE at any point, the  
>> resolution is restarted exactly once, and an additional flag is  
>> passed to the file system during each lookup that forces each  
>> component in the path to be revalidated on the server.  This has  
>> no possibility of causing an infinite loop.
>>
>> Is there some part of this logic that is no longer working?
>
> The VFS does not fully handle ESTALE.  An ESTALE error can occur
> during the second pathname resolution attempt.

If an ESTALE occurs during the second resolution attempt, we should  
give up.  When I addressed this issue two years ago, the two-try  
logic was the only acceptable solution because there's no way to  
guarantee the pathname resolution will ever finish unless we put a  
hard limit on it.

> There are lots of
> reasons, some of which are the 1 second resolution from some file
> systems on the server

Which is a server bug, AFAICS.  It's simply impossible to close all  
the windows that result from sloppy file time stamps without  
completely disabling client-side caching.  The NFS protocol relies on  
file time stamps to manage cache coherence.  If the server is lying  
about time stamps, there's no way the client can cache coherently.

> and the window in between the revalidation
> and the actual use of the file handle associated with each
> dentry/inode pair.

A use case or two would be useful to explore (on linux-nfs or linux- 
fsdevel, rather than lkml).

> Also, there was no support for ESTALE errors which occur during
> subsequent operations to the pathname resolution process.  For
> example, during a mkdir(2) operation, the ESTALE can occur from
> the over the wire MKDIR operation after the LOOKUP operations
> have all succeeded.

If the final operation fails after a pathname resolution, then it's a  
real error.  Is there a fixed and valid recovery script for the  
client in this case that will allow the mkdir to proceed?

Admittedly, the NFS client could recover more cleanly from some of  
these problems, but given the architecture of the Linux VFS, it will  
be difficult to address some of the corner cases.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
