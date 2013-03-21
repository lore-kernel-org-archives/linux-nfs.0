Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f50.google.com ([209.85.210.50]:40229 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098Ab3CURTJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 13:19:09 -0400
Received: by mail-da0-f50.google.com with SMTP id t1so246177dae.23
        for <linux-nfs@vger.kernel.org>; Thu, 21 Mar 2013 10:19:08 -0700 (PDT)
Date: Fri, 22 Mar 2013 01:18:50 +0800
From: Peng Tao <bergwolf@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH v2 1/3] NFSv4.1: Fix a race in pNFS layoutcommit
Message-ID: <20130321171850.GB4581@X61>
References: <1363875181-7147-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1363875181-7147-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 21, 2013 at 10:12:59AM -0400, Trond Myklebust wrote:
> We need to clear the NFS_LSEG_LAYOUTCOMMIT bits atomically with the
> NFS_INO_LAYOUTCOMMIT bit, otherwise we may end up with situations
> where the two are out of sync.
> The first half of the problem is to ensure that pnfs_layoutcommit_inode
> clears the NFS_LSEG_LAYOUTCOMMIT bit through pnfs_list_write_lseg.
> We still need to keep the reference to those segments until the RPC call
> is finished, so in order to make it clear _where_ those references come
> from, we add a helper pnfs_list_write_lseg_done() that cleans up after
> pnfs_list_write_lseg.
> 
I don't see any harm to block layout client in all the three patches.
Thanks for sorting it out.

Best,
Tao
