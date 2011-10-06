Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39766 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563Ab1JFMwt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Oct 2011 08:52:49 -0400
Received: by wyg34 with SMTP id 34so2768338wyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 06 Oct 2011 05:52:47 -0700 (PDT)
Message-ID: <4E8DA49A.6@tonian.com>
Date: Thu, 06 Oct 2011 14:52:42 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: Block layout status
References: <20110929165253.GC3724@umich.edu>
In-Reply-To: <20110929165253.GC3724@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-09-29 19:52, Jim Rees wrote:
> Since the call doesn't seem to be happening, here's my status.
> 
> On 16 Sep I sent these bug fixes to Trond for 3.1:
> 
> Jim Rees (2):
>   pnfsblock: fix size of upcall message     
>   pnfsblock: fix return code confusion          
> Peng Tao (3):
>   pnfsblock: fix NULL pointer dereference                
>   pnfsblock: fix writeback deadlock   
>   pnfsblock: add missing rpc_put_mount and path_put
> 
> These are the ones I think are important enough, and low enough risk to
> anyone else, that they should be considered for 3.1 even though it's late in
> the release cycle.  They have not shown up upstream.  Trond?
> 
> On 22 Sep I sent these to Trond for 3.2.  I believe these are all in Benny's
> tree now (sorry about that, Benny):
> 
> Jim Rees (2):
>   pnfsblock: fix return code confusion
>   pnfsblock: fix size of upcall message
> Peng Tao (8):
>   SUNRPC/NFS: make rpc pipe upcall generic
>   pnfsblock: add missing rpc_put_mount and path_put
>   pnfs: make _set_lo_fail generic
> - pnfsblock: init pg_bsize properly
>   pnfs: recoalesce when ld write pagelist fails
>   pnfs: recoalesce when ld read pagelist fails
>   pnfsblock: fix NULL pointer dereference
>   pnfsblock: fix writeback deadlock
> 
> This includes all the bug fixes for 3.1 plus some others that are less
> important or higher risk.  Notice that "init pg_bsize properly" is wrong and
> should not be used.  Benny, you may want to remove this from your tree, or I
> can send a revert patch.

Done.  Released under pnfs-all-3.1-rc8-2011-10-06

Thanks,

Benny

> 
> Missing from these is one more, "nfs4: serialize layoutcommit" that's
> important but I somehow missed it.
> 
> The recent automount changes really screwed us up but I just built a kernel
> from Linus's latest, which includes the patches from Trond, and it passes
> all tests so I think we're still ok for 3.1.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
