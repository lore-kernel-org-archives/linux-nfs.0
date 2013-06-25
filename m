Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15703 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267Ab3FYWKy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 18:10:54 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/5] NFS: Save FSID's root FH in nfs_server
Date: Tue, 25 Jun 2013 22:10:53 +0000
Message-ID: <1372198247.17600.17.camel@leira.trondhjem.org>
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
	 <20130625162405.36416.83658.stgit@seurat.1015granger.net>
	 <1372178216.5968.30.camel@leira.trondhjem.org>
	 <3B05A214-E7E5-474B-8F51-12E64A608B8A@oracle.com>
	 <1372194900.17600.6.camel@leira.trondhjem.org>
	 <2EFD4576-C5AA-4295-9DB2-A5E6BAD5061B@oracle.com>
In-Reply-To: <2EFD4576-C5AA-4295-9DB2-A5E6BAD5061B@oracle.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-06-25 at 17:51 -0400, Chuck Lever wrote:
> On Jun 25, 2013, at 5:15 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > On Tue, 2013-06-25 at 13:22 -0700, Chuck Lever wrote:
> >> On Jun 25, 2013, at 12:37 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> >> 
> >>> On Tue, 2013-06-25 at 12:24 -0400, Chuck Lever wrote:
> >>>> Save each FSID's root file handle in the FSID's nfs_server structure
> >>>> on the client.  This is needed for NFSv4 migration recovery.
> >>> 
> >>> Please just use sb->s_root.
> >> 
> >> The migration recovery procedures do not take an inode or dentry argument.  All we have is an nfs_server.  I see
> >> 
> >>  struct nfs_server *server = NFS_SB(sb);
> >> 
> >> but what is the preferred method for going the other way?  A naive approach would be to plant a super_block back-pointer in each nfs_server.
> > 
> > Why do you not have an inode or dentry?
> 
> That's the way the APIs happen to be architected.  I wasn't certain that exception->inode in nfs4_handle_exception(), and state->inode in nfs4_async_handle_error(), would always be non-NULL when I needed an inode pointer.

That should be fixable.

> > Surely the migration must have
> > been triggered either by an operation involving a filehandle, in which
> > case you have an inode, or by a LEASE_MOVED, in which case there is open
> > state on the target filesystem.
> 
> It's quite convenient to always use the FSID's root FH, but I agree, it's not required by the protocol.

The problem is that there is no single root FH in NFSv4. The existence
of the pseudofs means that you can have several points of entry to the
same filesystem. Then there are Linux bind mounts...

> Re: LEASE_MOVED, I'm not confident the client stops sending RENEW operations when it has no more open state.

That shouldn't matter. The server isn't allowed to reply with
LEASE_MOVED in that situation.

> > I'm not opposed to putting a backpointer to the super_block in the
> > nfs_server, but I do want to understand why it is needed.
> 
> 
> Alternately, we could save a pointer to the FSID's root dentry or inode.
> 


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
