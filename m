Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58589 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752684Ab1HOW1Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2011 18:27:24 -0400
Date: Mon, 15 Aug 2011 18:27:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, nfsv4@ietf.org
Subject: Re: open() of device special files
Message-ID: <20110815222721.GC32181@fieldses.org>
References: <20110815153637.GD28629@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9B9FB@SACMVEXC2-PRD.hq.netapp.com>
 <20110815212539.GA32181@fieldses.org>
 <20110815222336.GB32181@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110815222336.GB32181@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 15, 2011 at 06:23:36PM -0400, J. Bruce Fields wrote:
> On Mon, Aug 15, 2011 at 05:25:39PM -0400, J. Bruce Fields wrote:
> > On Mon, Aug 15, 2011 at 09:03:30AM -0700, Myklebust, Trond wrote:
> > > > -----Original Message-----
> > > > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > > > How is the client supposed to handle opens of device special files?
> > > On
> > > > a 3.1-rc1-based client to a linux server over v4.0 I'm seeing it try
> > > an
> > > > OPEN call and failing when it gets an INVAL return.
> > > > 
> > > > This looks like bogus client behavior (OPEN should fail on such
> > > files),
> > > > unless the server has the error return wrong and the client's using an
> > > > OPEN error to recover.
> > > > 
> > > > If I first stat the device and then open it then it works as expected
> > > > (the client does an open of the local device).
> > > > 
> > > > I'm a bit annoyed at myself as I have a feeling we've discussed this
> > > > before but I can't find a reference now.
> > > 
> > > Hmm... NFS4ERR_INVAL means 'invalid argument', which is not the case
> > > here; all the arguments that the client is passing to the server are
> > > valid, however the file cannot be opened because the pathname resolves
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
> 
> EINVAL seems to be used in the kernel for some such cases as well (e.g.
> attempt to truncate a device special file).
> 
> > > I can't see any other error definition that is "obviously correct", but
> > > it looks to me as if NFS4ERR_SYMLINK might be the closest thing. One
> > > reason is the dot-x file defines NFS4ERR_SYMLINK as meaning "should be
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
> > > _always_ trigger the correct behaviour on a client: a fresh lookup of
> > > the component.
> > 
> > Confirmed the fix; I'll apply.
> 
> Applying anyway for compatibility with existing clients, but this all
> seems a little weird.

And the change also makes a bunch of pynfs tests fail, complaining that
various operations against incompatible types should have returned INVAL
and not SYMLINK.

Not that I'm convinced pynfs is correct--at the very least it should
have accepted a range of errors for those tests, I think--but anyone
else that ran pynfs against their server may have assumed it pynfs was
correct in these cases....

--b.
