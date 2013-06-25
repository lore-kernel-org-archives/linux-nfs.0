Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:35581 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab3FYVPI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 17:15:08 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/5] NFS: Save FSID's root FH in nfs_server
Date: Tue, 25 Jun 2013 21:15:06 +0000
Message-ID: <1372194900.17600.6.camel@leira.trondhjem.org>
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
	 <20130625162405.36416.83658.stgit@seurat.1015granger.net>
	 <1372178216.5968.30.camel@leira.trondhjem.org>
	 <3B05A214-E7E5-474B-8F51-12E64A608B8A@oracle.com>
In-Reply-To: <3B05A214-E7E5-474B-8F51-12E64A608B8A@oracle.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-06-25 at 13:22 -0700, Chuck Lever wrote:
> On Jun 25, 2013, at 12:37 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > On Tue, 2013-06-25 at 12:24 -0400, Chuck Lever wrote:
> >> Save each FSID's root file handle in the FSID's nfs_server structure
> >> on the client.  This is needed for NFSv4 migration recovery.
> > 
> > Please just use sb->s_root.
> 
> The migration recovery procedures do not take an inode or dentry argument.  All we have is an nfs_server.  I see
> 
>   struct nfs_server *server = NFS_SB(sb);
> 
> but what is the preferred method for going the other way?  A naive approach would be to plant a super_block back-pointer in each nfs_server.

Why do you not have an inode or dentry? Surely the migration must have
been triggered either by an operation involving a filehandle, in which
case you have an inode, or by a LEASE_MOVED, in which case there is open
state on the target filesystem.

I'm not opposed to putting a backpointer to the super_block in the
nfs_server, but I do want to understand why it is needed.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
