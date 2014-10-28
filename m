Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:56271 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755824AbaJ1IfY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 04:35:24 -0400
Date: Tue, 28 Oct 2014 01:35:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: convert nfs4_file searches to use RCU
Message-ID: <20141028083522.GA25532@infradead.org>
References: <1413541275-3884-1-git-send-email-jlayton@primarydata.com>
 <1414065662-23341-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1414065662-23341-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
