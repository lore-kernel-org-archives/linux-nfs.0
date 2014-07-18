Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:34627 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761674AbaGRPzD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 11:55:03 -0400
Date: Fri, 18 Jul 2014 08:55:01 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v4 03/10] nfsd: simplify stateid allocation and file
 handling
Message-ID: <20140718155501.GB23745@infradead.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
 <1405696416-32585-4-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405696416-32585-4-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

(although the description still feels a little vague..)
