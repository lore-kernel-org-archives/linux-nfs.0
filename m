Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:56494 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbaG0NTX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 09:19:23 -0400
Date: Sun, 27 Jul 2014 06:19:17 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Cc: trond.myklebust@primarydata.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [PATCH] nfs3_list_one_acl(): check get_acl() result with
 IS_ERR_OR_NULL
Message-ID: <20140727131917.GA32153@infradead.org>
References: <1406375881-18837-1-git-send-email-andrey.krieger.utkin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406375881-18837-1-git-send-email-andrey.krieger.utkin@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 26, 2014 at 02:58:01PM +0300, Andrey Utkin wrote:
> There was a check for result being not NULL. But get_acl() may return
> NULL, or ERR_PTR, or actual pointer.
> The purpose of the function where current change is done is to "list
> ACLs only when they are available", so any error condition of get_acl()
> mustn't be elevated, and returning 0 there is still valid.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=81111
> Signed-off-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>

Looks good, thanks!

Reviewed-by: Christoph Hellwig <hch@lst.de>

should probably get a cc to stable as the original patch has one
as well.
