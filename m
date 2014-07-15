Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51195 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932418AbaGORDU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:03:20 -0400
Date: Tue, 15 Jul 2014 10:03:19 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/7] sunrpc: clean up sparse endianness warnings in
 gss_krb5_seal.c
Message-ID: <20140715170319.GB7767@infradead.org>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
 <1405303064-9102-6-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405303064-9102-6-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 13, 2014 at 09:57:42PM -0400, Jeff Layton wrote:
> KG2_TOK_MIC is a "palindrome" so byte swapping is a no-op here.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
