Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58713 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757094Ab3BVPjQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 10:39:16 -0500
Date: Fri, 22 Feb 2013 10:39:13 -0500
To: Steve Dickson <steved@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] NFS v4.2 support to both the server and client (take
 2)
Message-ID: <20130222153913.GE20588@fieldses.org>
References: <1361522832-11177-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1361522832-11177-1-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 22, 2013 at 03:47:10AM -0500, Steve Dickson wrote:
> These patche added v4.2 support to both the server and client. 
> Basically the v4.1 code is reused, but the minor version is 
> needed to enable features like label NFS.

Same comments as on previous patches.

(Sorry didn't notice there was another posting!)

--b.

> 
> Note, these patch apply on top of the lNFS: 3.8-rc3 release
> patches. Although the only conflict if applied without those patches
> would be in the Kconfig files 
> 
> Steve Dickson (2):
>   NFSv4.2: Added NFS v4.2 support to the NFS client
>   NFSDv4.2: Added NFS v4.2 support to the NFS server
> 
>  fs/nfs/Kconfig       | 12 +++++++++++-
>  fs/nfs/callback.c    |  3 +++
>  fs/nfs/nfs4client.c  |  5 +++++
>  fs/nfs/nfs4proc.c    |  3 +++
>  fs/nfs/super.c       |  7 ++++++-
>  fs/nfsd/nfs4xdr.c    |  1 +
>  fs/nfsd/nfsd.h       |  2 +-
>  include/linux/nfs4.h |  4 ++++
>  8 files changed, 34 insertions(+), 3 deletions(-)
> 
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
