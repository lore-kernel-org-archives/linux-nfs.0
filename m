Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:37964 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755608AbaFWQC2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:02:28 -0400
Date: Mon, 23 Jun 2014 09:02:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@primarydata.com>
Subject: Re: [PATCH v1 004/104] nfsd4: use cl_lock to synchronize all stateid
 idr calls
Message-ID: <20140623160227.GB24193@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <1403189450-18729-5-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403189450-18729-5-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This looks reasonable to me.  Am I right to assume this is just a
preparation for the state lock removal?  As far as I can tell currently
all calls are under nfs4_lock_state().

Reviewed-by: Christoph Hellwig <hch@lst.de>

assuming it gets a proper patch description.

