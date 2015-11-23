Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42949 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751215AbbKWTNo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2015 14:13:44 -0500
Date: Mon, 23 Nov 2015 14:13:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>, kernel-janitors@vger.kernel.org,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: constify nfsd4_callback_ops structure
Message-ID: <20151123191344.GD12032@fieldses.org>
References: <1448143059-3523-1-git-send-email-Julia.Lawall@lip6.fr>
 <20151122175742.GA21902@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151122175742.GA21902@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 22, 2015 at 09:57:42AM -0800, Christoph Hellwig wrote:
> Thanks, this looks good.  I should have add the const from the start.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks, applying for 4.5.--b.
