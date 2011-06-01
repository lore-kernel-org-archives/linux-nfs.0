Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11986 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751609Ab1FATRY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 15:17:24 -0400
Subject: Re: [PATCH] NFS: filelayout should use nfs_generic_pg_test
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Fred Isaman <iisaman@netapp.com>, Weston Andros Adamson <dros@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>, trond@netapp.com,
        linux-nfs@vger.kernel.org
Date: Wed, 01 Jun 2011 15:17:07 -0400
In-Reply-To: <4DE68B59.3030402@panasas.com>
References: <1306898310-9229-1-git-send-email-dros@netapp.com>
		<4DE5D287.603@panasas.com>
		<09816808-BA7B-4EAF-A18A-866B5A98BF25@netapp.com>
		<4DE65202.2010502@panasas.com>
	 <BANLkTi=Bwuuar76phVyEguB1Amqn4Q70Fw@mail.gmail.com>
	 <4DE68B59.3030402@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306955827.3873.60.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-06-01 at 21:56 +0300, Benny Halevy wrote:

> For pnfs, we need to ignore wsize, meaning we first need to try
> to coalesce the pages and then decide if we're going the nfs_flush_multi
> or the nfs_flush_one way, based on the coalesced length.

No! Ignoring the wsize is definitely wrong... If the stripe size is
larger than the 'maxwrite' recommended attribute, then the DS is allowed
to do a short write, in which case we have to resend.

In any case, nfs_flush_multi and nfs_flush_one need a rewrite in order
to deal properly with O_DIRECT writes, and so I'm expecting to get rid
of the single nfs_page limit for the r/wsize<PAGE_SIZE case.
Please don't make any large changes to this code at this time.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

