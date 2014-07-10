Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36000 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbaGJLdb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 07:33:31 -0400
Date: Thu, 10 Jul 2014 04:33:30 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 007/100] nfsd: Add fine grained protection for the
 nfs4_file->fi_stateids list
Message-ID: <20140710113330.GC7257@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-8-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404842668-22521-8-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 08, 2014 at 02:02:55PM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Access to this list is currently serialized by the client_mutex. Add
> finer grained locking around this list in preparation for its removal.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
