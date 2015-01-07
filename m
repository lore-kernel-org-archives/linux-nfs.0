Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:55689 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112AbbAGP20 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2015 10:28:26 -0500
Message-ID: <54AD5098.9000905@Netapp.com>
Date: Wed, 7 Jan 2015 10:28:24 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] NFS: Add READ_PLUS support
References: <1418855726-14262-1-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1418855726-14262-1-git-send-email-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

*bump*

Has anybody had a chance to look at these patches?

Anna

On 12/17/2014 05:35 PM, Anna Schumaker wrote:
> These patches add client support for the NFS v4.2 operation READ_PLUS.  This
> operation is triggered by doing any kind of read on a NFS v4.2 mounted
> filesystem.  `
> 
> The spec allows for the server to return multiple data and hole segments when
> reading a file.  Supporting this would requre a tedious amount of shifiting
> to make sure data is aligned properly, so I'm skipping this feature until I
> figure out a clean way of coding it.
> 
> These patches and the corresponding server changes are available in the
> [read_plus] branch of
> 
> 	git://git.linux-nfs.org/projects/anna/linux-nfs.git
> 
> Questions?  Comments?  Thoughts?
> 
> Anna
> 
> 
> Anna Schumaker (3):
>   NFS: Add basic support for READ_PLUS
>   SUNRPC: Add the ability to zero out data pages
>   NFS: Add support for reading NFS4_CONTENT_HOLE segments
> 
>  fs/nfs/nfs42xdr.c          | 159 +++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/nfs4proc.c          |  30 ++++++++-
>  fs/nfs/nfs4xdr.c           |   1 +
>  include/linux/nfs4.h       |   1 +
>  include/linux/nfs_fs_sb.h  |   1 +
>  include/linux/nfs_xdr.h    |   2 +-
>  include/linux/sunrpc/xdr.h |   1 +
>  net/sunrpc/xdr.c           |  45 +++++++++++++
>  8 files changed, 237 insertions(+), 3 deletions(-)
> 

