Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea01.nsa.gov ([63.239.67.1]:35385 "EHLO
	msux-gh1-uea01.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964794Ab0BZOCm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Feb 2010 09:02:42 -0500
Subject: Re: [PATCH 5/5] NFSv3: Add server namespace support for XATTR
 protocol implementation
From: Stephen Smalley <sds@tycho.nsa.gov>
To: James Morris <jmorris@namei.org>
Cc: linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Dave Quigley <dpquigl@tycho.nsa.gov>,
        "Serge E. Hallyn" <serue@us.ibm.com>
In-Reply-To: <alpine.LRH.2.00.1002261537020.25193@tundra.namei.org>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>
	 <alpine.LRH.2.00.1002261537020.25193@tundra.namei.org>
Content-Type: text/plain
Date: Fri, 26 Feb 2010 08:46:30 -0500
Message-Id: <1267191990.7691.37.camel@moss-pluto.epoch.ncsc.mil>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-02-26 at 15:37 +1100, James Morris wrote:
> Add support for a server namespace for storing and retrieving
> client-supplied xattrs.  All xattrs are now stored on the server under
> the user._nfsd namespace, and are not interpreted by the server at all.
> This allows clients to utilize arbitrary xattr namespaces and for the
> server to act only as a storage mechanism for the xattrs.
> 
> The user._nfsd namespace was chosen because filesystems generally have
> a user. xattr handler implemented.  Using something like system. would
> require implementing a generalized handler for each backing fs on the
> server, as well as requiring privilege to access.

I'm wondering whether the user. namespace is best for storage on the
server given that:
- the user. namespace is restricted to regular files or directories (see
xattr_permission()), and
- the user. namespace applies its own set of permission checking logic
that we don't necessarily want applied in the case of trusted. or
security. attributes (e.g. special rules on sticky directories and read
or write access to the file, see xattr_permission()), and
- storing the attributes in the user. namespace would allow local users
on the server to manipulate them directly.  I know that you stated an
assumption that end users do not have local access to the exported
filesystem, but it would be better if the system itself would restrict
the ability to set these attributes to privileged processes on the
server.

Using the security. or trusted. namespace would avoid the restriction on
file type and require CAP_SYS_ADMIN on setxattr.  That would prevent
local modification by non-admins and should have no effect on clients
(since nfsd doesn't drop CAP_SYS_ADMIN).

> Currently, only the user and trusted namespaces are supported by
> the client, as system and security namespaces require further analysis,
> and some special-case handling will be required (for security.selinux,
> at least).
> 
> NFS ACLs continue to work as expected, because they implement a
> hard-coded system xattr namespace which is invoked before the
> NFS layer.  e.g. any access to a system.posix_acl_access xattr
> is invokes the NFS_ACL protocol.

-- 
Stephen Smalley
National Security Agency

