Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:60514 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753963AbZJEQe2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Oct 2009 12:34:28 -0400
From: Andreas Gruenbacher <agruen@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Date: Mon, 5 Oct 2009 18:31:55 +0200
Cc: Steve French <smfrench@gmail.com>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        ffilzlnx@linux.vnet.ibm.com, linux-nfs@vger.kernel.org,
        nfsv4@linux-nfs.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        jra@samba.org
References: <524f69650909021156lf181c17uf800eba7c35a6f45@mail.gmail.com> <20090902202206.GJ17884@fieldses.org>
In-Reply-To: <20090902202206.GJ17884@fieldses.org>
Content-Type: text/plain;
  charset="iso-8859-1"
Message-Id: <200910051831.56157.agruen@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wednesday 02 September 2009 22:22:06 J. Bruce Fields wrote:
> On Wed, Sep 02, 2009 at 01:56:23PM -0500, Steve French wrote:
> > In the meantime we don't even have a generalized system interface to
> > set/get nfsv4/cifs/ntfs acls
> 
> The current client is using raw xdr-formatted v4 acls in an extended
> attribute.  We could consider some other interface if that would be more
> useful to other projects.  (Andreas' patches have a different
> xattr-based interface which might serve as another example.)

Yes, the current nfsv4 client exposes NFSv4 ACLs with "user@domain" and 
"group@domain" identifiers in xattrs. Users and groups of local processes and 
files are are identified by ID though, so the kernel would have to map between 
"user@domain" and "group@domain" identifiers and IDs even for local accesses. 
This doesn't make sense. The native NSFv4 ACL prototype [1] uses IDs in its 
xattr format instead; all the ID mapping logic remains in NFSv4 (and in Samba 
for CIFS).

[1] http://www.suse.de/~agruen/nfs4acl/

Andreas
