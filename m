Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hapkido.dreamhost.com ([66.33.216.122]:60271 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757615Ab3J1XDM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 19:03:12 -0400
Received: from homiemail-a25.g.dreamhost.com (caiajhbdcagg.dreamhost.com [208.97.132.66])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 9B28EDF2C7
	for <linux-nfs@vger.kernel.org>; Mon, 28 Oct 2013 16:03:12 -0700 (PDT)
Date: Mon, 28 Oct 2013 18:02:29 -0500
From: Nico Williams <nico@cryptonector.com>
To: Marc Eshel <eshel@us.ibm.com>
Cc: nfsv4@ietf.org, Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] XATTRs in NFS
Message-ID: <20131028230206.GH15988@gmail.com>
References: <FD29488A-348B-48BA-9B1D-4ACF997BC794@netapp.com>
 <526EA65A.7010209@redhat.com>
 <20131028180838.GG31322@fieldses.org>
 <526EAD86.6090507@redhat.com>
 <OFA4C7B613.86F16AC7-ON88257C12.006FE486-88257C12.0071EE79@us.ibm.com>
 <C2C70C2E-100E-40BD-A919-A4F649077059@netapp.com>
 <20131028210247.GM31322@fieldses.org>
 <6AB20096-3993-47DD-AB58-2CD25F8A75D8@oracle.com>
 <OF3A48E6D9.7BB93CB0-ON88257C12.0075527E-88257C12.0075F065@LocalDomain>
 <OF9D091881.D4CDB064-ON88257C12.007629C1-88257C12.007B7AFE@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF9D091881.D4CDB064-ON88257C12.007629C1-88257C12.007B7AFE@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 03:28:42PM -0700, Marc Eshel wrote:
> This is a clean start to discuss extended attributes over NFS in the 
> mailing list first. 
> 
> 1. What are the requirements and why? which applications are using them 
> and how. 

Surely the requirements would be semantic compatibility with Linux's
xattrs.  These are defined in manpages such as getxattr(2).  Links can
be easily found online.

: ; man -s2 -k xattr
fgetxattr (2)        - retrieve an extended attribute value
flistxattr (2)       - list extended attribute names
fremovexattr (2)     - remove an extended attribute
fsetxattr (2)        - set an extended attribute value
getxattr (2)         - retrieve an extended attribute value
lgetxattr (2)        - retrieve an extended attribute value
listxattr (2)        - list extended attribute names
llistxattr (2)       - list extended attribute names
lremovexattr (2)     - remove an extended attribute
lsetxattr (2)        - set an extended attribute value
removexattr (2)      - remove an extended attribute
setxattr (2)         - set an extended attribute value
: ; 

Whether there are apps that use them is a different story.  I've no
idea, but here's a github search for code using getxattr:

https://github.com/search?q=getxattr&ref=cmdform&type=Code

Many of the results are from clones of Android, so one has to wade a
fair bit to find apps.  Things like this:

https://github.com/protonet/xattr
https://github.com/jarib/ffi-xattr

make it harder to tell what's using them.

Then we have:

https://github.com/search?q=getxattr&ref=cmdform&type=Issues

which is a bit better, since this brings up more issues with apps using
xattrs and fewer about implementations of xattrs, like:

https://github.com/Cocoanetics/DTFoundation/issues/37

Even then, most of the issues (only 5 pages) relate to filesystems and
FUSE.

Interesting data point: both, an OS X port of ZFS, and ZFSOnLinux felt
the need to add support for xattrs.

The only apps I found this way are the above DTFoundation, Ruby FFI
bindings of xattrs, and:

https://github.com/tobiaswaldvogel/openwrt-addpack
https://github.com/mxcl/homebrew
https://github.com/scrod/nv
https://github.com/ShareKit/ShareKit

> 2. Why are current named attributes in NFS not the right answer.

They have different semantics and namespaces.

xattrs are small, bite-sized.

Named attributes as files within files -"forks"- and align well with
openat(2) but not with *xattr(2).

> 3. What does the new protocol enhancements should look like? 

Probably like direct equivalents of the xattrs system calls as OPs
operating on the current FH.  This seems like the simplest question to
answer.

I'm not advocating adding xattrs to the protocol.  I'm not sure there's
a real case for this.  Developers ought to be using openat(2) more and
xattrs less.  Forks interop better with, e.g., Win32, than xattrs.

Perhaps xattrs could be implemented as a conventional mapping onto named
attributes.  This would require agreement by many people, including
implementors of filesystems that already have both features, so it seems
unlikely, except, perhaps, via reserving named attribute namespace for
implementation purposes, but even that I think is (IIRC) not allowable
for NFSv4 (i.e., the named attribute namespace is already wide open for
use by the public).

This really brings up a different matter: to the extent that xattrs and
named attributes are used to store application data (as opposed to
arbitrary user-named attributes) perhaps we ought to have a registry for
naming them.

Nico
-- 
