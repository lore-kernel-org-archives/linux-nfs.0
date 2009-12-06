From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCHSET 00/12 repost] nfsd: #includes cleanup
Date: Sun, 06 Dec 2009 11:36:46 +0200
Message-ID: <4B1B7B2E.8070004@panasas.com>
References: <4B1802D0.8060206@panasas.com> <20091205010004.GC22497@fieldses.org> <20091205010310.GE22497@fieldses.org> <20091205010411.GF22497@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50127 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756156AbZLFJgm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Dec 2009 04:36:42 -0500
In-Reply-To: <20091205010411.GF22497@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/05/2009 03:04 AM, J. Bruce Fields wrote:
> And as long as we're there....
> 
> --b.
> 
> commit 987dc26d179e6359d9c9d9250c060633d4306025
> Author: J. Bruce Fields <bfields@citi.umich.edu>
> Date:   Fri Dec 4 19:49:00 2009 -0500
> 
>     nfsd: remove pointless paths in file headers
>     
>     The new .h files have paths at the top that are now out of date.  While
>     we're here, just remove all of those from fs/nfsd; they never served any
>     purpose.
>     

Wawoo thanks. Sorry about that. I totally missed it.

>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> 

Boaz
