Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:50637 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935167Ab0BZEdk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Feb 2010 23:33:40 -0500
Date: Fri, 26 Feb 2010 15:33:30 +1100 (EST)
From: James Morris <jmorris@namei.org>
To: linux-nfs@vger.kernel.org
cc: linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Subject: [PATCH 0/5][v3][RFC] NFSv3: implement extended attribute protocol
 (XATTR)
Message-ID: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is version 3 of the NFSv3 XATTR protocol extension patches, which 
I've previously posted:

v1: http://thread.gmane.org/gmane.linux.file-systems/35475
v2: http://thread.gmane.org/gmane.linux.nfs/30539

The main change in this version is the addition of support for storing 
xattrs in a local namespace on the server, following feedback from Trond.

The wire protocol and client view is unchanged.  The server now stores all 
xattrs received via the XATTR protocol in a special namespace: user._nfsd.  
This allows arbitrary xattrs to be manipulated by clients, with the server 
providing xattr storage only, and no interpretation of the xattrs.

For example, if the client sets an xattr named "user.icon", it will be 
transferred as such to the server via the XATTR protocol, and the server 
will store it locally as "user._nfsd.user.icon".

This is entirely transparent to the user and works similarly getxattr(2) 
and removexattr(2).  The server filters listxattr(2) to only return xattr 
names with this prefix (with the prefix stripped).

e.g. when the client calls getxattr(2) for "user.icon", this is translated 
at the server to "user._nfsd.user.icon", and the associated value 
is returned to the client.

The changes for this are in the last patch in the set (which also includes 
a bugfix), so they can be reviewed separately.

I chose the user._nfsd namespace, rather than, say, a system. namespace, 
because filesystems which support xattrs tend already have a generalized 
user. xattr handler.  If we don't use user., then new xattr handlers will 
need to be implemented for each backing fs.

An assumption is made that the server is under administrative control, and 
that end users do not have local access to the exported filesystems.

The '_nfsd' component of the namespace could be made a per-export 
configuration value (as also discussed with Trond), although I've kept 
things as simple as possible at this stage.

Note that only the user. and trusted. namespaces are supported on the 
client at this stage (except for system.posix_acl*, which is handled by 
the NFS_ACL protocol).  This is also keep things initially simple, as 
we'll need to make SELinux and possibly other security/system xattr users 
aware of the NFS_XATTR protocol, but aside from that, it should be 
possible to extend this scheme to arbitrary client xattr namespaces.

Please review and comment.


- James
-- 
James Morris
<jmorris@namei.org>
