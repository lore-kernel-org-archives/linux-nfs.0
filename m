From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 0/3] enhanced ESTALE error handling
Date: Fri, 18 Jan 2008 11:55:15 -0500
Message-ID: <4790D9F3.2070503@redhat.com>
References: <4790C756.2040704@redhat.com> <63F84201-9D38-4588-B237-A15138E94C5A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757647AbYARQzr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2008 11:55:47 -0500
In-Reply-To: <63F84201-9D38-4588-B237-A15138E94C5A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> Hi Peter-
>
> On Jan 18, 2008, at 10:35 AM, Peter Staubach wrote:
>> Hi.
>>
>> Here is a patch set which modifies the system to enhance the
>> ESTALE error handling for system calls which take pathnames
>> as arguments.
>
> The VFS already handles ESTALE.
>
> If a pathname resolution encounters an ESTALE at any point, the 
> resolution is restarted exactly once, and an additional flag is passed 
> to the file system during each lookup that forces each component in 
> the path to be revalidated on the server.  This has no possibility of 
> causing an infinite loop.
>
> Is there some part of this logic that is no longer working? 

The VFS does not fully handle ESTALE.  An ESTALE error can occur
during the second pathname resolution attempt.  There are lots of
reasons, some of which are the 1 second resolution from some file
systems on the server and the window in between the revalidation
and the actual use of the file handle associated with each
dentry/inode pair.

Also, there was no support for ESTALE errors which occur during
subsequent operations to the pathname resolution process.  For
example, during a mkdir(2) operation, the ESTALE can occur from
the over the wire MKDIR operation after the LOOKUP operations
have all succeeded.

    Thanx...

       ps
