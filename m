Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:35883 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482AbbDHR6B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 13:58:01 -0400
Date: Wed, 8 Apr 2015 10:57:54 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] mountstats: Resync NFSv4 Operations List
Message-ID: <20150408175754.GA16208@infradead.org>
References: <1428511647-14920-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1428511647-14920-2-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1428511647-14920-2-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 08, 2015 at 12:47:26PM -0400, Anna Schumaker wrote:
> We've added several operations and removed GETDEVICELIST,  Let's keep
> the Nfsv4ops list up to date with the kernel.

Please keep GETDEVICELIST, as newer mountstats should handle older
kernels as well.
