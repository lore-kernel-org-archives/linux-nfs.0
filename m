Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39364 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbbCYNvf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 09:51:35 -0400
Date: Wed, 25 Mar 2015 06:51:32 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] nfsd: return correct openowner when there is a race
 to put one in the hash
Message-ID: <20150325135132.GA9720@infradead.org>
References: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
 <1427122424-8078-2-git-send-email-jeff.layton@primarydata.com>
 <20150325084516.GC25682@infradead.org>
 <20150325062833.1f5ad592@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150325062833.1f5ad592@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Let's just keep your version for simplicity for now..
