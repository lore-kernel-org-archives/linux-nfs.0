Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58835 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbaELISq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 May 2014 04:18:46 -0400
Date: Mon, 12 May 2014 01:18:46 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 07/43] nfsd4: allow space for final error return
Message-ID: <20140512081846.GB14194@infradead.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-8-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1399841568-19716-8-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 11, 2014 at 04:52:12PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> This post-encoding check should be taking into account the need to
> encode at least an out-of-space error to the following op (if any).
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
