Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59077 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295Ab1HPKth (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2011 06:49:37 -0400
Date: Tue, 16 Aug 2011 06:49:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, nfsv4@ietf.org
Subject: Re: open() of device special files
Message-ID: <20110816104932.GB5829@fieldses.org>
References: <20110815153637.GD28629@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9B9FB@SACMVEXC2-PRD.hq.netapp.com>
 <20110815212539.GA32181@fieldses.org>
 <20110815222336.GB32181@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9BE52@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9BE52@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 15, 2011 at 10:03:49PM -0700, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > The long description of NFS4ERR_INVAL from rfc 3530:
> > 
> > 	"Invalid argument or unsupported argument for an operation. Two
> > 	examples are attempting a READLINK on an object other than a
> > 	symbolic link or specifying a value for an enum field that is
> > 	not defined in the protocol (e.g., nfs_ftype4)."
> > 
> > So the text does recommend NFS4ERR_INVAL for the case where the
> > operation doesn't make sense for the type of object given.  (In the
> > readlink example there's no pathname resolution, though).
> 
> Right. In the case of readlink, you pass a file handle, which points to
> an object for which you _can_ check the type before attempting the
> readlink operation.
> 
> OPEN (and LOOKUP, RENAME, REMOVE,...) takes a filename, which could
> point to anything. There is no way for the client to know a priori the
> type of the object being pointed to.
> 
> > EINVAL seems to be used in the kernel for some such cases as well
> (e.g.
> > attempt to truncate a device special file).
> 
> My reading of the manpages and the posix spec is that truncate() will
> return EINVAL if and only if the length argument is wrong. Ftruncate()
> will in addition return EINVAL if the file descriptor points to a
> non-regular file (the assumption presumably being that you should have
> tried to fstat() first).
> 
> IOW: The criterion that they apply is that "if the user should have
> known better" then EINVAL is correct. If there is no way for the user to
> be sure a priori, then it is not. So, for instance, rmdir() will not
> return EINVAL if you try to apply it to a file.

That's perfectly logical, but, taking the example of (f)truncate:

	- truncate(2) as far as I can tell doesn't specify behavior for
	  truncate in this case, only for ftruncate.

	- http://pubs.opengroup.org/onlinepubs/009695399/ says behavior
	  is undefined for ftruncate, and says nothing for truncate.

	- linux actually returns EINVAL in both cases:

	  $ sudo mknod tmp c 1 3 -m 666
	  $ make trunc-vs-ftrunc
	  cc     trunc-vs-ftrunc.c   -o trunc-vs-ftrunc
	  $ ./trunc-vs-ftrunc tmp
	  trunc-vs-ftrunc: truncate: Invalid argument
	  trunc-vs-ftrunc: ftruncate: Invalid argument

But I don't really know why I'm arguing here--I don't disagree.  You
have a reasonable way to define EINVAL.  This just appears to be easy to
get wrong....

--b.

trunc-vs-ftrunc.c:
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <err.h>

int main(int argc, char *argv[])
{
	int fd, ret;

	if (argc != 2)
		errx(1, "usage: %s path\n", argv[0]);
	ret = truncate(argv[1], 0);
	if (ret)
		warn("truncate");
	fd = open(argv[1], O_WRONLY);
	if (fd < 0)
		err(1, "open");
	ret = ftruncate(fd, 0);
	if (ret)
		warn("ftruncate");
}
