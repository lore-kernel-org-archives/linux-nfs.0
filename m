Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:45433 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaJ1NXq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 09:23:46 -0400
Date: Tue, 28 Oct 2014 06:23:45 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eryu Guan <eguan@redhat.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] generic/277: add _require_attrs
Message-ID: <20141028132345.GB26453@infradead.org>
References: <1414502171-10319-1-git-send-email-eguan@redhat.com>
 <1414502171-10319-5-git-send-email-eguan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1414502171-10319-5-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 28, 2014 at 09:16:11PM +0800, Eryu Guan wrote:
> NFS doesn't support attr yet, add _require_attrs in generic/277 to avoid
> failure when testing on NFS.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
