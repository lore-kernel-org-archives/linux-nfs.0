Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47342 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbbCYIpy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 04:45:54 -0400
Date: Wed, 25 Mar 2015 01:45:52 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, trond.myklebust@primarydata.com, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] nfsd: remove bogus setting of status in
 nfsd4_process_open2
Message-ID: <20150325084552.GD25682@infradead.org>
References: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
 <1427122424-8078-3-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1427122424-8078-3-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
