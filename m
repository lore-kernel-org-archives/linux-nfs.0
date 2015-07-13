Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57070 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbbGMHDr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 03:03:47 -0400
Date: Mon, 13 Jul 2015 00:03:46 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/9] NFS: Remove nfs4_match_stateid()
Message-ID: <20150713070346.GJ26245@infradead.org>
References: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1436561897-8051-7-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1436561897-8051-7-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 10, 2015 at 04:58:14PM -0400, Anna Schumaker wrote:
> Let's just call nfs4_stateid_match() directly.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
