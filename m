Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57741 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbDMRpt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2015 13:45:49 -0400
Date: Mon, 13 Apr 2015 10:45:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFS: Add stubs for GETDEVICELIST
Message-ID: <20150413174538.GA22583@infradead.org>
References: <1428680559-26705-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1428680559-26705-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 10, 2015 at 11:42:39AM -0400, Anna Schumaker wrote:
> d4b18c3e (pnfs: remove GETDEVICELIST implementation) removed the
> GETDEVICELIST operation from the NFS client, but left a "hole" in the
> nfs4_procedures array.  This caused /proc/self/mountstats to report an
> operation named "51" where GETDEVICELIST used to be.  This patch adds
> back stubs to fix mountstats.

The only thing we need here is the name, right?  Why not add a STUB
macro that just fills out the name field?
