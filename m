Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58164 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752159AbcFOUW3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2016 16:22:29 -0400
Date: Wed, 15 Jun 2016 16:22:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [V5 0/2] Super simple flex file server
Message-ID: <20160615202227.GC3848@fieldses.org>
References: <1465936888-103341-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1465936888-103341-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 14, 2016 at 01:41:26PM -0700, Tom Haynes wrote:
> Hi Bruce,
> 
> The following patches make a flex file server in which
> the mds and the ds are the same machine. And the same inode
> services both metadata and data.

Thanks, applying for 4.8.

--b.
> 
> v5:
> - Fix the stripe unit size as reported by Tigran
> 
> v4:
> - The addr len in a netaddr is INET6_ADDRSTRLEN + 8
> 
> v3:
> - Extra word help for selecting NFSD_FLEXFILELAYOUT
> - Do not allow WRITE permissions on an IOMODE_READ segment
> 
> v2:
> - Remove patch 2: nfsd: Can leak pnfs_block_extent on error
> - Consolidate 3rd and 4th patch
> - Fix the rsize and wsize to come out of the rqstp as per Jeff's
>   review comments
> - Sort the available layout types such that scsi beats block which
>   beats flex file
> - Address the points brought up by Christoph in his review
> 
> These patches are also in my flex_server branch at
> git://git.linux-nfs.org/projects/loghyr/linux-nfs.git
> 
> Thanks,
> Tom
> 
> Tom Haynes (2):
>   nfsd: flex file device id encoding will need the server address
>   nfsd: Add a super simple flex file server
> 
>  fs/nfsd/Kconfig             |  17 ++++++
>  fs/nfsd/Makefile            |   1 +
>  fs/nfsd/blocklayout.c       |   2 +
>  fs/nfsd/flexfilelayout.c    | 133 ++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/flexfilelayoutxdr.c | 115 ++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/flexfilelayoutxdr.h |  49 ++++++++++++++++
>  fs/nfsd/nfs4layouts.c       |  12 +++-
>  fs/nfsd/nfs4proc.c          |   2 +-
>  fs/nfsd/pnfs.h              |   4 ++
>  9 files changed, 333 insertions(+), 2 deletions(-)
>  create mode 100644 fs/nfsd/flexfilelayout.c
>  create mode 100644 fs/nfsd/flexfilelayoutxdr.c
>  create mode 100644 fs/nfsd/flexfilelayoutxdr.h
> 
> -- 
> 1.8.3.1
