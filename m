Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33791 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbbHQOm5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2015 10:42:57 -0400
Date: Mon, 17 Aug 2015 07:42:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/6] NFSv4.1/pnfs: Don't prevent layoutgets when doing
 return-on-close
Message-ID: <20150817144256.GA30167@infradead.org>
References: <1438741796-22681-1-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-2-git-send-email-trond.myklebust@primarydata.com>
 <1438741796-22681-3-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1438741796-22681-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This break the block layout client badly.  With this patch applied
it silently hangs in xfstests generic/001.  I'll see if I can
get more details out of my test setup.
