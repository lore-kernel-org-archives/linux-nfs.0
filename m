Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:36518 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813Ab0CIIOE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 03:14:04 -0500
Date: Tue, 9 Mar 2010 19:13:45 +1100 (EST)
From: James Morris <jmorris@namei.org>
To: Brad Boyer <flar@allandria.com>
cc: linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 0/6][v4][RFC] NFSv3: implement extended attribute protocol
 (XATTR)
In-Reply-To: <20100309035932.GA14237@cynthia.pants.nu>
Message-ID: <alpine.LRH.2.00.1003091834450.12164@tundra.namei.org>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org> <alpine.LRH.2.00.1003082122340.6314@tundra.namei.org> <20100309035932.GA14237@cynthia.pants.nu>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 8 Mar 2010, Brad Boyer wrote:

> I personally think it's a bad idea to not map regular user xattr values
> directly to what is local to the server. One common thing I've seen in
> many places is to have local disks on various servers exported over
> NFS to other servers, but the intent is that the user shouldn't care
> which server physically hosts the storage. In this case, you want the
> data to appear the same regardless of the use or non-use of NFS. In
> this sort of situation, one system will see different data than the
> others for the same files with the same access level. One possible
> option would be to make it configurable, kind of like root_squash.

It should be straightforward to make it configurable, although I wonder if 
this might end up leading to more confusion for admins.  They'll always 
have to remember how they exported each filesystem.  If they ever mount a 
filesystem with the wrong option, and users start accessing it, they could 
end up with an unfixable mess.

The core issue is that we don't want system-level xattrs being stored on 
the server.

As you suggest, perhaps we always leave 'user' xattrs untranslated on the 
server, with an expectation that they're always opaque to the server and 
managed entirely by user applications.

I don't think we can meaningfully do this for 'trusted' xattrs, as we 
don't know how to extend CAP_SYS_ADMIN over NFS.  So, this, and all other 
non-user namespaces (e.g. 'system', 'security') are mapped on the server 
to the 'nfsd' namespace, on the basis that they would otherwise require 
interpretation by the server, which we want to avoid.  (Note that there's 
an exception here for POSIX ACLs, which already use a well-defined 
protocol over NFS).

Here's a summary of the mappings:

Client                    Server

user.a                    user.a
trusted.a                 nfsd.trusted.a
system.a                  nfsd.system.a
security.a                nfsd.security.a

Special cases:

  if ACL protocol enabled on server:

system.posix_acl_access   system.posix_acl_access
system.posix_acl_default  system.posix_acl_default
  
  if ACL protocol not enabled on server:

system.posix_acl_access   [error]
system.posix_acl_default  [error]

This also ensures that nothing about the existing NFS ACL support changes.

'user' xattrs simply work as expected, whether accessed locally or 
remotely.  

How does this sound?



- James
-- 
James Morris
<jmorris@namei.org>
