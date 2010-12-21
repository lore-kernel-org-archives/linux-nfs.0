Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:41643 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402Ab0LUPVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Dec 2010 10:21:04 -0500
Date: Tue, 21 Dec 2010 10:21:04 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 03/14] pnfs: wave 2: rename lo->state to lo->plh_flags
Message-ID: <20101221152104.GB30248@infradead.org>
References: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
 <1292898046-7336-4-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1292898046-7336-4-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 20, 2010 at 09:20:35PM -0500, Fred Isaman wrote:
> Preparing for change in stateid code, and want to avoid name confusion.

None of the other fields in struct pnfs_layout_hdr has a prefix.  Either
do it for all of them or none, but this version is rather inconsistant.

