Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:56713 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752908Ab0FUL0b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jun 2010 07:26:31 -0400
Date: Mon, 21 Jun 2010 21:25:56 +1000 (EST)
From: James Morris <jmorris@namei.org>
To: linux-nfs@vger.kernel.org
cc: linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>
Subject: [PATCH 0/8][v05][RFC] NFSv3: implement extended attribute protocol
 (XATTR)
Message-ID: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is version 5 of the NFSv3 XATTR protocol extension patches, which 
I've previously posted as:
 
v1: http://thread.gmane.org/gmane.linux.file-systems/35475
v2: http://thread.gmane.org/gmane.linux.nfs/30539
v3: http://thread.gmane.org/gmane.linux.nfs/30971
v4: http://thread.gmane.org/gmane.linux.kernel.lsm/10562

In the previous version, I implemented a new top-level xattr namespace on 
the server, which is used to store client-supplied xattrs, e.g.:

client: user.a        ->       server: nfsd.user.a

In this version, I've enhanced support for security xattrs, and updated 
SELinux so that it can utilize the XATTR protocol for security labeling.

I added a new NFS error code, NFSERR_NODATA, so that we can cleanly handle 
cases where the xattr system calls on the server return -ENODATA to 
indicate a non-existent xattr (this is often not an error condition).

Also new are the xattr and xattrsec mount options, which are used to 
control the use of the XATTR protocol and XATTR security labeling 
respectively (see patch #7).

The userspace patch for the mount utility is available at:
http://namei.org/nfsv3xattr/v05/userspace/

The XATTR code also now calls back into the LSM during file creation so 
that an appropriate security label may be installed at the same time 
(atomically from the client pov).  This follows the behavior of the ACL 
code (see nfs3_init_xattr() in patch #6).

For SELinux, the approach is to allow both genfs (the current labeling 
behavior) and xattr labeling.  To support the latter, an fs_use_xattr 
statement needs to be added to policy for NFS:

http://namei.org/nfsv3xattr/v05/policy/

By default, mounts will still use genfs, unless the admin also supplies 
the new 'xattrsec' mount option, to indicate to the security module that 
it should use the XATTR protocol for labeling.  If XATTR is unavailable, 
the mount will fail (and not fall back to genfs).


This code still has several major todo items (mostly marked in the code), 
and needs much more testing, although I'd like to get feedback from the 
NFS and security folk on the current approach.

Comments welcome.


- James
-- 
James Morris
<jmorris@namei.org>
