Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44333 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbbKVR5q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Nov 2015 12:57:46 -0500
Date: Sun, 22 Nov 2015 09:57:42 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, kernel-janitors@vger.kernel.org,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: constify nfsd4_callback_ops structure
Message-ID: <20151122175742.GA21902@infradead.org>
References: <1448143059-3523-1-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1448143059-3523-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, this looks good.  I should have add the const from the start.

Reviewed-by: Christoph Hellwig <hch@lst.de>
