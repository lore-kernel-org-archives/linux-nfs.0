Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57854 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab3IHJQU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Sep 2013 05:16:20 -0400
Date: Sun, 8 Sep 2013 02:16:13 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: 4 DCACHE_DISCONNECTED patches
Message-ID: <20130908091613.GA17535@infradead.org>
References: <1378579561-26868-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1378579561-26868-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Sep 07, 2013 at 02:45:57PM -0400, J. Bruce Fields wrote:
> This is a resend of some DCACHE_DISCONNECTED patches incorporating
> suggestions from Christoph.

The whole series looks good to me,

Reviewed-by: Christoph Hellwig <hch@lst.de>
