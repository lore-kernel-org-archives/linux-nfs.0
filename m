Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57845 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932125AbbDQIUB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Apr 2015 04:20:01 -0400
Date: Fri, 17 Apr 2015 01:20:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3] NFS: Add a stub for GETDEVICELIST
Message-ID: <20150417082000.GB11876@infradead.org>
References: <1429022060-11222-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1429022060-11222-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 14, 2015 at 10:34:20AM -0400, Anna Schumaker wrote:
> d4b18c3e (pnfs: remove GETDEVICELIST implementation) removed the
> GETDEVICELIST operation from the NFS client, but left a "hole" in the
> nfs4_procedures array.  This caused /proc/self/mountstats to report an
> operation named "51" where GETDEVICELIST used to be.  This patch adds a
> stub to fix mountstats.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
