Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:42717 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab3FYUWr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 16:22:47 -0400
MIME-Version: 1.0
Message-ID: <3B05A214-E7E5-474B-8F51-12E64A608B8A@oracle.com>
Date: Tue, 25 Jun 2013 13:22:21 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/5] NFS: Save FSID's root FH in nfs_server
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
 <20130625162405.36416.83658.stgit@seurat.1015granger.net>
 <1372178216.5968.30.camel@leira.trondhjem.org>
In-Reply-To: <1372178216.5968.30.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 25, 2013, at 12:37 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-06-25 at 12:24 -0400, Chuck Lever wrote:
>> Save each FSID's root file handle in the FSID's nfs_server structure
>> on the client.  This is needed for NFSv4 migration recovery.
> 
> Please just use sb->s_root.

The migration recovery procedures do not take an inode or dentry argument.  All we have is an nfs_server.  I see

  struct nfs_server *server = NFS_SB(sb);

but what is the preferred method for going the other way?  A naive approach would be to plant a super_block back-pointer in each nfs_server.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




