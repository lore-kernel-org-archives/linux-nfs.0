Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:63919 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881AbaIIRtO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 13:49:14 -0400
Message-ID: <540F3D87.803@Netapp.com>
Date: Tue, 9 Sep 2014 13:48:55 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Marc Eshel <eshel@us.ibm.com>, Anna Schumaker <Anna.Schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>, <linux-nfs-owner@vger.kernel.org>,
        <Trond.Myklebust@primarydata.com>
Subject: Re: [PATCH 0/2] NFS: Add ALLOCATE and DEALLOCATE support
References: <1410274196-30841-1-git-send-email-Anna.Schumaker@Netapp.com> <OFCC7C8976.B925FBA7-ON88257D4E.00604587-88257D4E.0060D8A0@us.ibm.com>
In-Reply-To: <OFCC7C8976.B925FBA7-ON88257D4E.00604587-88257D4E.0060D8A0@us.ibm.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/09/2014 01:37 PM, Marc Eshel wrote:
> Hi Anna,
>
> Did you get a chance to set up a git tree with all your changes, at least 
> for the client side, maybe Trond will include it in his tree?
I did for SEEK.  I haven't updated it to include these patches yet, but I will after making the changes that Trond and Christoph are asking for.

git://git.linux-nfs.org/projects/anna/linux-nfs.git  (see the "seek" branch)

Anna
>
> Thanks, Marc. 
>
>
> From:   Anna Schumaker <Anna.Schumaker@netapp.com>
> To:     <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>, 
> Date:   09/09/2014 07:50 AM
> Subject:        [PATCH 0/2] NFS: Add ALLOCATE and DEALLOCATE support
> Sent by:        linux-nfs-owner@vger.kernel.org
>
>
>
> These patches add client support for the ALLOCATE and DEALLOCATE 
> operations
> part of NFS v4.2.
>
> These operations are triggered by a vfs_fallocate() call, and we determine
> which to use based on if the FALLOC_FL_PUNCH_HOLE flag is set.
>
> Anna Schumaker (2):
>   nfs: Add ALLOCATE support
>   nfs: Add DEALLOCATE support
>
>  fs/nfs/nfs42proc.c        |  74 +++++++++++++++++++++++++
>  fs/nfs/nfs42xdr.h         | 136 
> ++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/nfs4_fs.h          |   3 +
>  fs/nfs/nfs4client.c       |   2 +-
>  fs/nfs/nfs4file.c         |  47 ++++++++++++++++
>  fs/nfs/nfs4proc.c         |   2 +-
>  fs/nfs/nfs4xdr.c          |   2 +
>  include/linux/nfs4.h      |   2 +
>  include/linux/nfs_fs_sb.h |   2 +
>  include/linux/nfs_xdr.h   |  28 ++++++++++
>  10 files changed, 296 insertions(+), 2 deletions(-)
>

