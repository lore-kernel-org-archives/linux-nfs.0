Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:62202 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670AbcEXUUz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 May 2016 16:20:55 -0400
Subject: Re: [PATCH 0/3] FF_FLAGS_NO_READ_IO
To: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
References: <1463605676-82483-1-git-send-email-loghyr@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <d3be85ff-b066-0f9f-cb35-c18790b39b73@Netapp.com>
Date: Tue, 24 May 2016 16:20:51 -0400
MIME-Version: 1.0
In-Reply-To: <1463605676-82483-1-git-send-email-loghyr@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tom,

I'm having trouble applying these patches:

Applying: nfs/flexfiles: Helper function to detect FF_FLAGS_NO_READ_IO
fatal: sha1 information is lacking or useless (fs/nfs/flexfilelayout/flexfilelayout.h).
error: could not build fake ancestor
Patch failed at 0001 nfs/flexfiles: Helper function to detect FF_FLAGS_NO_READ_IO

And attempting to apply using patch(1) has failed chunks.  Do you have an updated version of these?

Thanks,
Anna


On 05/18/2016 05:07 PM, Tom Haynes wrote:
> FF_FLAGS_NO_READ_IO is a hint the mds can use to inform the
> client that an IOMODE_RW layout segment should not be used
> for READ traffic and that the client should instead request
> an IOMODE_READ layout segment. This can be used to isolate
> only WRITE traffic onto the IOMODE_RW layout segment.
> 
> Tom Haynes (3):
>   nfs/flexfiles: Helper function to detect FF_FLAGS_NO_READ_IO
>   nfs/flexfiles: Use the layout segment for reading unless it a
>     IOMODE_RW and reading is disabled
>   pnfs: pnfs_update_layout needs to consider if strict iomode checking
>     is on
> 
>  fs/nfs/filelayout/filelayout.c            |  2 ++
>  fs/nfs/flexfilelayout/flexfilelayout.c    | 50 +++++++++++++++++++++++--------
>  fs/nfs/flexfilelayout/flexfilelayout.h    | 10 ++++++-
>  fs/nfs/flexfilelayout/flexfilelayoutdev.c |  6 ++++
>  fs/nfs/pnfs.c                             | 34 +++++++++++++--------
>  fs/nfs/pnfs.h                             |  1 +
>  6 files changed, 77 insertions(+), 26 deletions(-)
> 

