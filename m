Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37621 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754318Ab0KPS1F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Nov 2010 13:27:05 -0500
Date: Tue, 16 Nov 2010 13:27:04 -0500
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>,
        sfaibish <sfaibish@emc.com>
Subject: Re: fileid changed
Message-ID: <20101116182703.GB3971@fieldses.org>
References: <20101115191533.GA31837@merit.edu>
 <20101115201000.GC31906@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101115201000.GC31906@merit.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Nov 15, 2010 at 03:10:00PM -0500, Jim Rees wrote:
> Jim Rees wrote:
> 
>   With Benny's pnfs-all-latest kernel of this morning I'm getting this:
>   
>   NFS: server emc-1 error: fileid changed
>   fsid 0:14: expected fileid 0x4c1b59f7, got 0x167
>   NFS: server emc-1 error: fileid changed
>   fsid 0:14: expected fileid 0x4c891415, got 0x174
>   NFS: server emc-1 error: fileid changed
>   fsid 0:14: expected fileid 0x174, got 0x4c891415
>   NFS: server emc-1 error: fileid changed
>   fsid 0:14: expected fileid 0x177, got 0x4ce18474
>   [ followed by many similar lines ]

Naively, it sounds like the server is returning different fileid's for
getattr's on the same filehandle?  Sounds like a definite server
bug--might be worth looking at a trace to confirm that, though.

--b.

>   
>   This happens during test5: read and write of Connectathon basic, pnfs block
>   layout client, EMC server.  The user process hangs at this point, no oops.
>   I can provide more details if needed.  This could easily be my screw-up of
>   course, but I haven't changed anything in my code and I wasn't getting this
>   with the previous kernel.
> 
> Sorry, I was mistaken.  I was getting this with the previous kernel as
> well.  I'm still interested to know if anyone recognizes this.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
