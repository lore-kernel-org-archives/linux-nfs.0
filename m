Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8558 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041Ab3FYQhF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 12:37:05 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/5] NFS: Save FSID's root FH in nfs_server
Date: Tue, 25 Jun 2013 16:37:02 +0000
Message-ID: <1372178216.5968.30.camel@leira.trondhjem.org>
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
	 <20130625162405.36416.83658.stgit@seurat.1015granger.net>
In-Reply-To: <20130625162405.36416.83658.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-06-25 at 12:24 -0400, Chuck Lever wrote:
> Save each FSID's root file handle in the FSID's nfs_server structure
> on the client.  This is needed for NFSv4 migration recovery.

Please just use sb->s_root.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
