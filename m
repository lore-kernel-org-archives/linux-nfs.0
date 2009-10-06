From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Tue, 06 Oct 2009 11:18:24 -0400
Message-ID: <4ACB5FC0.7060307@redhat.com>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	linux-fsdevel@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753891AbZJFPTJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Oct 2009 11:19:09 -0400
In-Reply-To: <alpine.LRH.2.00.0909200020360.31818-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

James Morris wrote:
> This patchset is the initial posting of an implementation of extended 
> attribute support for the Linux NFSv3 code, and intended as an RFC.
> 
> This code is based initially on the GPL'd NFSv3 xattr code from IRIX 
> (thanks, Casey!), as well as the existing Linux NFSv3 ACL code. It is 
> implemented as a side-protocol and should not affect any existing protocol 
> operation.  These patches are against the devel branch of the linux-nfs 
> tree.
> 
> Currently, the code is implemented only to support Linux namespace.name 
> xattrs in the "user" namespace.  It could be extended to support other 
> similar name/value pair xattr implementations (and not far from IRIX wire 
> compat), although that's not an aim of this version.  There may also be 
> some scope for limited support of system xattrs (e.g. 'dumb' security 
> label transport), although I've not looked beyond user.* so far.
> 
> Three operations are implemented by the new XATTR protocol and map to 
> syscalls:
> 
>  - GETXATTR     getxattr(2)
>  - LISTXTTR     listxattr(2)
>  - SETXATTR     setxattr(2) and removexattr(2)
> 
> This code passes basic testing of the above syscalls, although there are 
> some areas which still need work:
> 

Is there a set of tests which are used to test this functionality?

>  - Dynamic allocation of RPC buffers/pages (currently, the max size of 
>    e.g. the getxattr(2) value buffer is allocated at the RPC layer for 
>    each call -- suggestions on the best approach for this welcome)
> 
>  - Determine appropriate NFS error codes for each operation
> 
>  - Formal documentation of the XATTR protocol
> 

These two would be a good thing.  It would be good to at least have
a .x description, although having some of the semantics described
as well would be a good thing.

>  - Interoperability with other OSs (we probably should at least
>    discuss with BSD folk)
> 

It would be good to include the BSD folks, but I think that more
valuable targets would be those with volume servers that might be
encountered at customer sites.  I think that we need NetApp, EMC,
perhaps Sun, providing some feedback on the protocol and semantics.

>  - Handle size probing for getxattr(2) and listxattr(2) in the client 
>    (currently faked).  I think we should handle this at the client and not 
>    support it over the wire, as probes are almost always followed 
>    immediately by full calls, and the protocol can be kept simpler by 
>    expecting the client to perform a full call over the wire in response 
>    to a userland probe and caching the result.
> 
>  - Caching of xattrs at the client
> 

This will need a closer specification for the semantics associated
with these xattrs.  The need will be how to determine when to
invalidate cached xattrs.

On more bullet that I might suggest is ensuring that the protocol
is compliant with the RPC and XDR standards.

	Thanx...

		ps


> Please review and comment!
> 
> Note that I'll be giving a talk on this at LinuxCon on Thursday: 
> http://linuxcon.linuxfoundation.org/meetings/1589 So, in addition to 
> discussion here, please come along to the talk if you're at the conf, and 
> we may also be able to discuss it at Plumbers in one of the BoFs.
> 
> Full diffstat:
> 
>  fs/nfs/Kconfig             |   36 ++++
>  fs/nfs/Makefile            |    2 
>  fs/nfs/client.c            |   51 ++++++
>  fs/nfs/dir.c               |    8 -
>  fs/nfs/file.c              |    8 -
>  fs/nfs/internal.h          |   19 ++
>  fs/nfs/nfs3acl.c           |  155 +++++++++++--------
>  fs/nfs/nfs3xattr.c         |  264 +++++++++++++++++++++++++++++++++
>  fs/nfs/nfs3xattr_user.c    |   52 ++++++
>  fs/nfs/nfs3xdr.c           |  187 +++++++++++++++++++++++
>  fs/nfs/super.c             |    3 
>  fs/nfsd/Kconfig            |    8 +
>  fs/nfsd/Makefile           |    1 
>  fs/nfsd/nfs3xattr.c        |  352 +++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfsctl.c           |    3 
>  fs/nfsd/nfssvc.c           |   60 +++++++
>  fs/nfsd/vfs.c              |    5 
>  include/linux/nfs_fs.h     |   16 --
>  include/linux/nfs_fs_sb.h  |    3 
>  include/linux/nfs_mount.h  |    3 
>  include/linux/nfs_xattr.h  |   21 ++
>  include/linux/nfs_xdr.h    |   45 +++++
>  include/linux/nfsd/nfsd.h  |   13 +
>  include/linux/nfsd/xdr3.h  |   46 +++++
>  include/linux/sunrpc/svc.h |    2 
>  25 files changed, 1265 insertions(+), 98 deletions(-)
> 
> 
> - James

