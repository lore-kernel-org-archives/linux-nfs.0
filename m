From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: help: return_layout status: -10025 - NFS4ERR_BAD_STATEID
Date: Mon, 07 Jun 2010 15:07:09 +0300
Message-ID: <4C0CE0ED.1010309@panasas.com>
References: <4C0CDD31.2050507@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:56426 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755008Ab0FGMHL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2010 08:07:11 -0400
In-Reply-To: <4C0CDD31.2050507@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/07/2010 02:51 PM, Boaz Harrosh wrote:
> Benny hi.
> 
> Only With Panfs. On a pnfs-2.6.33 Kernel after very heavy IO (git clone linux)
> on the client side I get:
> 
> Jun  7 14:30:42 tl2 kernel: <-- return_layout status: -10025
> Jun  7 14:30:42 tl2 kernel: <-- _pnfs_return_layout status: -10025
> 
> On the server side at the FS level I see a normal:
> Jun  7 14:30:42 tl1 kernel: pan_kernel_fs_client_pnfs_layout_return: Begin I-xD02005194137f000f-xGe401b24c-xUb7850bdbb6117413 iomode=3 offs
> et=0x0 length=0xffffffffffffffff cookie=0x0
> Jun  7 14:30:42 tl1 kernel: pan_kernel_fs_client_pnfs_layout_return: released 3 caps
> Jun  7 14:30:42 tl1 kernel: pan_kernel_fs_client_pnfs_layout_return: Return 0
> 
> These happen for 5 6 different files that do need return at that particular point.
> (After Read was done and file closed by git)
> 
> And then everything at client side *freezes*.
> 
> 1. Why would the Server return NFS4ERR_BAD_STATEID?
> 2. Why would the Client freeze and do nothing after that?
> 
> I'll try to run with nfs Server debug on to see what happens. Did Bruce fix
> something like this for 2.6.34? or it was something else?
> 
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

At the server it all starts when:
Jun  7 14:59:11 tl1 kernel: NFSD: laundromat service - starting
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12626)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12627)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12628)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12629)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12630)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12631)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12632)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12633)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12634)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12635)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12636)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12637)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12638)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12639)
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 12640)
<...>
Jun  7 14:59:11 tl1 kernel: NFSD: purging unused open stateowner (so_id 13080)
Jun  7 14:59:11 tl1 kernel: NFSD: laundromat_main - sleeping for 82 seconds

At that point the client gets these 10025, and freezes.

I'll try pnfs-2.6.34 just for fun.

Boaz
