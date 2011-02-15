Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56978 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359Ab1BOJQU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 04:16:20 -0500
Date: Tue, 15 Feb 2011 04:16:18 -0500
From: Christoph Hellwig <hch@infradead.org>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/16] NFS remove unnecessary CONFIG_NFS_V4 from
 nfs_read_data
Message-ID: <20110215091618.GA29871@infradead.org>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
 <1297711116-3139-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1297711116-3139-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 14, 2011 at 02:18:21PM -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>

Either the patch or the description is incorrect.  If you actually need
it for NFSv2/3 the description should say it.  Otherwise it's just a
"cleanup" which bloats the structure for people not having v4 support
compiled in.

