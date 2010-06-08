Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51433 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963Ab0FHHeU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 03:34:20 -0400
Date: Tue, 8 Jun 2010 03:34:19 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 16/24] pnfs_submit: remove pnfs_file_operations
Message-ID: <20100608073419.GB12121@infradead.org>
References: <1275970761-31806-8-git-send-email-iisaman@netapp.com>
 <1275970761-31806-9-git-send-email-iisaman@netapp.com>
 <1275970761-31806-10-git-send-email-iisaman@netapp.com>
 <1275970761-31806-11-git-send-email-iisaman@netapp.com>
 <1275970761-31806-12-git-send-email-iisaman@netapp.com>
 <1275970761-31806-13-git-send-email-iisaman@netapp.com>
 <1275970761-31806-14-git-send-email-iisaman@netapp.com>
 <1275970761-31806-15-git-send-email-iisaman@netapp.com>
 <1275970761-31806-16-git-send-email-iisaman@netapp.com>
 <1275970761-31806-17-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1275970761-31806-17-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -ssize_t
> -pnfs_file_write(struct file *filp, const char __user *buf, size_t count,
> -		loff_t *pos)
> -{

Just doing this in ->write also means you were missing out on AIO
and vectored writes, so it can't have been a that big help.

