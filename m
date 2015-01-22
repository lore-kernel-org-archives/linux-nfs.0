Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:50134 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbbAVPpd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 10:45:33 -0500
Received: by mail-qc0-f179.google.com with SMTP id w7so1791494qcr.10
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 07:45:33 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 22 Jan 2015 10:45:30 -0500
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 03/20] fs: add FL_LAYOUT lease type
Message-ID: <20150122104530.44297670@tlielax.poochiereds.net>
In-Reply-To: <1421925006-24231-4-git-send-email-hch@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
	<1421925006-24231-4-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 22 Jan 2015 12:09:49 +0100
Christoph Hellwig <hch@lst.de> wrote:

> This (ab-)uses the file locking code to allow filesystems to recall
> outstanding pNFS layouts on a file.  This new lease type is similar but
> not quite the same as FL_DELEG.  A FL_LAYOUT lease can always be granted,
> an a per-filesystem lock (XFS iolock for the initial implementation)
> ensures not FL_LAYOUT leases granted when we would need to recall them.
> 
> Also included are changes that allow multiple outstanding read
> leases of different types on the same file as long as they have a
> differnt owner.  This wasn't a problem until now as nfsd never set
> FL_LEASE leases, and no one else used FL_DELEG leases, but given that
> nfsd will also issues FL_LAYOUT leases we will have to handle it now.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/locks.c         | 14 ++++++++++----
>  include/linux/fs.h | 16 ++++++++++++++++
>  2 files changed, 26 insertions(+), 4 deletions(-)
> 

Abuse indeed. :)

I'd probably prefer to move this to a separate list within the i_flctx
instead of overloading the lease stuff, but I'm not religious about it.

I can live with this for now, and if and when we get around to
representing different types of file locks with different types of
structures, we can do that conversion then.

Acked-by: Jeff Layton <jlayton@primarydata.com>
