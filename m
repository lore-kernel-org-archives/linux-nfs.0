Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26952 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752792Ab1G0UNS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:13:18 -0400
Subject: Re: [PATCH v3 22/25] pnfsblock: note written INVAL areas for
 layoutcommit
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Wed, 27 Jul 2011 16:13:17 -0400
In-Reply-To: <1311792048-12551-23-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
	 <1311792048-12551-23-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311797597.25645.26.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 14:40 -0400, Jim Rees wrote: 
> From: Fred Isaman <iisaman@citi.umich.edu>
> 
> [SQUASHME: pnfs: blocklayout: port block layout code]
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ?




> +int mark_for_commit(struct pnfs_block_extent *be,
> +		    sector_t offset, sector_t length);

This is an externally visible function, so it needs a prefix.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

