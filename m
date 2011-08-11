Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34828 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007Ab1HKMTS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 08:19:18 -0400
Received: by wwf5 with SMTP id 5so1987951wwf.1
        for <linux-nfs@vger.kernel.org>; Thu, 11 Aug 2011 05:19:17 -0700 (PDT)
Message-ID: <4E43C8BE.9040108@tonian.com>
Date: Thu, 11 Aug 2011 15:19:10 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCHSET 0/4] exofs & pnfsd-exofs assorted changes
References: <4E42F3E3.8050006@panasas.com>
In-Reply-To: <4E42F3E3.8050006@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-08-11 00:10, Boaz Harrosh wrote:
> 
> Submitted are, a changes to upstream exofs, and some proper fixes
> to pnfsd-exofs.
> 
> the patches:
> [PATCH 1/4] exofs: Remove unused data_map member from exofs_sb_info
> 
> 	This patch will be put in linux-next for the 3.2 merge window
> 
> [PATCH 2/4] SQUASHME: pnfsd-exofs: Convert to ORE (2)
> [PATCH 3/4] ore: Make ore_calc_stripe_info EXPORT_SYMBOL
> [PATCH 4/4] pnfsd-exofs: Serve out a single group layout at a time
> 
> 	These patches are for the pnfsd tree, including the ore
> 	one which has users only in the pnfsd tree for now.
> 
> Thanks
> Boaz
> 

Merged into pnfsd-exofs. Thanks!

Benny

P.S. I don't think my Panasas email address is still active
no need to send stuff there...
