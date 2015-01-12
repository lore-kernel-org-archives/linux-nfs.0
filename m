Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f181.google.com ([209.85.160.181]:62970 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbbALE4L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jan 2015 23:56:11 -0500
Received: by mail-yk0-f181.google.com with SMTP id 142so8387905ykq.12
        for <linux-nfs@vger.kernel.org>; Sun, 11 Jan 2015 20:56:10 -0800 (PST)
Date: Sun, 11 Jan 2015 23:56:06 -0500
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 14/18] nfsd: pNFS block layout driver
Message-ID: <20150112045606.GA107426@slacker.internal.excfb.com>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
 <1420561721-9150-15-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420561721-9150-15-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 05:28:37PM +0100, Christoph Hellwig wrote:
> Add a small shim between core nfsd and filesystems to translate the
> somewhat cumbersome pNFS data structures and semantics to something
> more palatable for Linux filesystems.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  .../filesystems/nfs/pnfs-block-server.txt          |  40 +++++
>  fs/nfsd/Makefile                                   |   2 +-
>  fs/nfsd/blocklayout.c                              | 194 +++++++++++++++++++++
>  fs/nfsd/blocklayoutxdr.c                           | 157 +++++++++++++++++
>  fs/nfsd/blocklayoutxdr.h                           |  62 +++++++
>  fs/nfsd/nfs4layouts.c                              |   7 +
>  fs/nfsd/pnfs.h                                     |   1 +
>  7 files changed, 462 insertions(+), 1 deletion(-)
>  create mode 100644 Documentation/filesystems/nfs/pnfs-block-server.txt
>  create mode 100644 fs/nfsd/blocklayout.c
>  create mode 100644 fs/nfsd/blocklayoutxdr.c
>  create mode 100644 fs/nfsd/blocklayoutxdr.h

Could you follow the client code convention by putting
each layout type in a directory?

lacker:linux loghyr$ ls -la fs/nfs/blocklayout/
total 80

