Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44709 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646Ab2DPQDp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Apr 2012 12:03:45 -0400
Date: Mon, 16 Apr 2012 12:04:18 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Peter Staubach <pstaubach@exagrid.com>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120416120418.6857d74f@corrin.poochiereds.net>
In-Reply-To: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E01D@IT-1874.Isys.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
	<20120416073655.7cdb90cf@corrin.poochiereds.net>
	<FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E01D@IT-1874.Isys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 16 Apr 2012 08:54:02 -0400
Peter Staubach <pstaubach@exagrid.com> wrote:

> There seems to be a lot of, perhaps, misinformation here.
> 
> The looping occurs when the file system on the server returns a valid file handle during a pathname traversal and then returns ESTALE on a subsequent operation.
> 
> The client should retry the pathname traversal, which should either return a valid file handle or ENOENT.  If a subsequent operation returns ESTALE, then start over again at the original pathname traversal.
> 
> The client should not loop when 1) there is a signal pending which would cause the system call to terminate with EINTR or when it can't recover from the ESTALE return.  For example, if lookup("./foo") returns ESTALE, then clearly the current directory has become stale and there is no way for the client to recover. 

I think it's reasonable to make the syscall "wrapper" break out of the
loop if there's a _fatal_ signal pending. At that point, we don't
necessarily care what the return was since the program is going to be
dying soon anyway.

Some filesystems (e.g. NFS) would already return a different error code
in that situation, but dealing with it here seems like a reasonable way
to mitigate problems from filesystems that do not deal with signals
themselves.

>One could make the argument that the client can recover by relooking up the current directory, which is fine, but eventually if the file handle for the root of the mounted file system is also stale, then there is no further recovery possible, at least for NFSv[23] and perhaps even for NFSv4 depending upon how the file system was mounted.

If it gets an ESTALE on the initial lookup, then the VFS will already
attempt to retry the lookup again with LOOKUP_REVAL set. IIUC, that
makes it revalidate all the way back up to the root. It currently does
this regardless of whether LOOKUP_REVAL was set on the initial lookup
attempt.

It sounds here like you're suggesting that we should just go ahead and
give up and return ESTALE to userspace if the root of the mount went
stale. So, if someone mistakenly unexports the fs on the server, these
operations would still fail with ESTALE.

If so, I'm OK with that since I'm not necessarily interested in making
that situation more recoverable. It would be a nice to have, but it's
not as essential as fixing these other situations where the ESTALE is
more easily recovered.

-- 
Jeff Layton <jlayton@redhat.com>
