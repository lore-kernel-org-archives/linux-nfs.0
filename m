Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17032 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092Ab1HPFFH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 01:05:07 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: open() of device special files
Date: Mon, 15 Aug 2011 22:03:49 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9BE52@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20110815222336.GB32181@fieldses.org>
References: <20110815153637.GD28629@fieldses.org> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9B9FB@SACMVEXC2-PRD.hq.netapp.com> <20110815212539.GA32181@fieldses.org> <20110815222336.GB32181@fieldses.org>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <steved@redhat.com>, <nfsv4@ietf.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Monday, August 15, 2011 6:24 PM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org; steved@redhat.com; nfsv4@ietf.org
> Subject: Re: open() of device special files
> 
> On Mon, Aug 15, 2011 at 05:25:39PM -0400, J. Bruce Fields wrote:
> > On Mon, Aug 15, 2011 at 09:03:30AM -0700, Myklebust, Trond wrote:
> > > > -----Original Message-----
> > > > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > > > How is the client supposed to handle opens of device special
> files?
> > > On
> > > > a 3.1-rc1-based client to a linux server over v4.0 I'm seeing it
> try
> > > an
> > > > OPEN call and failing when it gets an INVAL return.
> > > >
> > > > This looks like bogus client behavior (OPEN should fail on such
> > > files),
> > > > unless the server has the error return wrong and the client's
> using an
> > > > OPEN error to recover.
> > > >
> > > > If I first stat the device and then open it then it works as
> expected
> > > > (the client does an open of the local device).
> > > >
> > > > I'm a bit annoyed at myself as I have a feeling we've discussed
> this
> > > > before but I can't find a reference now.
> > >
> > > Hmm... NFS4ERR_INVAL means 'invalid argument', which is not the
> case
> > > here; all the arguments that the client is passing to the server
> are
> > > valid, however the file cannot be opened because the pathname
> resolves
> > > on the server to a file of the wrong type.
> 
> The long description of NFS4ERR_INVAL from rfc 3530:
> 
> 	"Invalid argument or unsupported argument for an operation. Two
> 	examples are attempting a READLINK on an object other than a
> 	symbolic link or specifying a value for an enum field that is
> 	not defined in the protocol (e.g., nfs_ftype4)."
> 
> So the text does recommend NFS4ERR_INVAL for the case where the
> operation doesn't make sense for the type of object given.  (In the
> readlink example there's no pathname resolution, though).

Right. In the case of readlink, you pass a file handle, which points to
an object for which you _can_ check the type before attempting the
readlink operation.

OPEN (and LOOKUP, RENAME, REMOVE,...) takes a filename, which could
point to anything. There is no way for the client to know a priori the
type of the object being pointed to.

> EINVAL seems to be used in the kernel for some such cases as well
(e.g.
> attempt to truncate a device special file).

My reading of the manpages and the posix spec is that truncate() will
return EINVAL if and only if the length argument is wrong. Ftruncate()
will in addition return EINVAL if the file descriptor points to a
non-regular file (the assumption presumably being that you should have
tried to fstat() first).

IOW: The criterion that they apply is that "if the user should have
known better" then EINVAL is correct. If there is no way for the user to
be sure a priori, then it is not. So, for instance, rmdir() will not
return EINVAL if you try to apply it to a file.

> > > I can't see any other error definition that is "obviously
correct",
> but
> > > it looks to me as if NFS4ERR_SYMLINK might be the closest thing.
> One
> > > reason is the dot-x file defines NFS4ERR_SYMLINK as meaning
"should
> be
> > > file/directory".
> 
> And this seems more a coincidence due to vagueness resulting from the
> need for a single-line comment; the longer description is:
> 
> 	"NFS4ERR_SYMLINK The current filehandle provided for a LOOKUP is
> 			 not a directory but a symbolic link.  Also used
> 			 if the final component of the OPEN path is a
> 			 symbolic link."
> 
> > > The other reason is that NFS4ERR_SYMLINK should
> > > _always_ trigger the correct behaviour on a client: a fresh lookup
> of
> > > the component.
> >
> > Confirmed the fix; I'll apply.
> 
> Applying anyway for compatibility with existing clients, but this all
> seems a little weird.

Agreed, but it appears to be a case that has been missed when we defined
OPEN.

Trond
