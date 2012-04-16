Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p02c11o142.mxlogic.net ([208.65.144.75]:52031 "EHLO
	p02c11o142.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639Ab2DPNlB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Apr 2012 09:41:01 -0400
From: Peter Staubach <pstaubach@exagrid.com>
To: Jeff Layton <jlayton@redhat.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
CC: Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Date: Mon, 16 Apr 2012 08:54:02 -0400
Subject: RE: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E01D@IT-1874.Isys.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
 <20120416073655.7cdb90cf@corrin.poochiereds.net>
In-Reply-To: <20120416073655.7cdb90cf@corrin.poochiereds.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There seems to be a lot of, perhaps, misinformation here.

The looping occurs when the file system on the server returns a valid file handle during a pathname traversal and then returns ESTALE on a subsequent operation.

The client should retry the pathname traversal, which should either return a valid file handle or ENOENT.  If a subsequent operation returns ESTALE, then start over again at the original pathname traversal.

The client should not loop when 1) there is a signal pending which would cause the system call to terminate with EINTR or when it can't recover from the ESTALE return.  For example, if lookup("./foo") returns ESTALE, then clearly the current directory has become stale and there is no way for the client to recover.  One could make the argument that the client can recover by relooking up the current directory, which is fine, but eventually if the file handle for the root of the mounted file system is also stale, then there is no further recovery possible, at least for NFSv[23] and perhaps even for NFSv4 depending upon how the file system was mounted.

I think that engaging again with Miklos and/or Bernd to understand why the underlying file system would return valid file identification information, but then be unable to use it in a subsequent operation.  The definition of ESTALE is that a file handle, which referred to a valid file, no longer refers to a valid file.  Why should FUSE impose any special requirements in this regard?  If FUSE has attempted to expand the definition of ESTALE, then we should consider this situation and perhaps make recommendations for a more appropriate errno to use.

The bottom line is that for pathname based system calls, the application should never see an ESTALE error.  The system call should either succeed or fail on its own merits or fail with ENOENT.

	Thanx...

		ps


-----Original Message-----
From: Jeff Layton [mailto:jlayton@redhat.com] 
Sent: Monday, April 16, 2012 7:37 AM
To: Bernd Schubert
Cc: Malahal Naineni; linux-nfs@vger.kernel.org; linux-fsdevel@vger.kernel.org; linux-kernel@vger.kernel.org; Peter Staubach; miklos@szeredi.hu; viro@ZenIV.linux.org.uk; hch@infradead.org; michael.brantley@deshaw.com; sven.breuner@itwm.fraunhofer.de
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr call

On Sun, 15 Apr 2012 21:03:23 +0200
Bernd Schubert <bernd.schubert@itwm.fraunhofer.de> wrote:

> On 04/13/2012 05:42 PM, Jeff Layton wrote:
> > (note: please don't trim the CC list!)
> > 
> > Indefinitely does make some sense (as Peter articulated in his 
> > original set). It's possible you could race several times in a row, 
> > or a server misconfiguration or something has happened and you have 
> > a transient error that will eventually recover. His assertion was 
> > that any limit on the number of retries is by definition wrong. For 
> > NFS, a fatal signal ought to interrupt things as well, so retrying 
> > indefinitely has some appeal there.
> > 
> > OTOH, we do have to contend with filesystems that might return 
> > ESTALE persistently for other reasons and that might not respond to signals.
> > Miklos pointed out that some FUSE fs' do this in his review of 
> > Peter's set.
> > 
> > As a purely defensive coding measure, limiting the number of retries 
> > to something finite makes sense. If we're going to do that though, 
> > I'd probably recommend that we set the number of retries be 
> > something higher just so that this is more resilient in the face of 
> > multiple races. Those other fs' might "spin" a bit in that case but 
> > it is an error condition and IMO resiliency trumps performance -- at 
> > least in
>  this case.
> 
> I am definitely voting against an infinite number of retries. I'm 
> working on FhGFS, which supports distributed meta data servers. So 
> when a file is moved around between directories, its file handle, 
> which contains the meta-data target id might become invalid. As NFSv3 
> is stateless we cannot inform the client about that and must return 
> ESTALE then. NFSv4 is better, but I'm not sure how well invalidating a 
> file handle works. So retrying once on ESTALE might be a good idea, 
> but retrying forever is not.

It's important to note that I'm only proposing to wrap syscalls this way that take a pathname argument. We can't do anything about those that don't since at that point we have no way to retry the lookup.

So, I'm not sure this patch would affect the case you're concerned about one way or another. If you move the file to a different directory, then it's pathname would also change, and at that point you'd end up with an ENOENT error or something on the next retry.

If the file was open and you were (for instance) reading or writing to it from a client when you moved it, then we can't retry the lookup at that point. The open is long since done and the pathname is now gone.
You'll get an ESTALE back in userspace regardless.

> Also, what about asymmetric HA servers? I believe to remember that 
> also resulted in ESTALE. So for example server1 exports /home and 
> /scratch, but on failure server2 can only take over /home and denies 
> access to /scratch.
> 

That sounds like a broken cluster configuration. Still...

Presumably at some point in the future, a sysadmin would intervene and fix the situation such that /scratch is available again. Is it better to return an error to the application at that point, or simply allow it to keep retrying until the problem has been fixed?

The person with the long running job that's doing operations in /scratch would probably prefer the latter. If not, then they could always send the program a fatal signal to stop it altogether.

--
Jeff Layton <jlayton@redhat.com>
