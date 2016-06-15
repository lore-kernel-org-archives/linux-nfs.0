Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:50097 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932951AbcFOOxb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 10:53:31 -0400
Date: Wed, 15 Jun 2016 07:53:30 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 11/12] NFS: Don't count O_DIRECT reads in the
 inode->i_dio_count
Message-ID: <20160615145330.GA5297@infradead.org>
References: <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-11-git-send-email-trond.myklebust@primarydata.com>
 <20160615071605.GD4318@infradead.org>
 <C9DCA08F-F8FE-41FD-978B-8B1CAF3DEB17@primarydata.com>
 <20160615144150.GA18524@infradead.org>
 <B4354EF8-B0AB-43C6-B7C3-FD27E43364B1@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B4354EF8-B0AB-43C6-B7C3-FD27E43364B1@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 15, 2016 at 02:50:07PM +0000, Trond Myklebust wrote:
> Fair enough. So it sounds as if you are suggesting we can just drop using inode_dio_*() altogether?

Maybe.  The big question is how a direct write vs truncate race is
handled.  Either way I think a patch like this deserves a detailed
analysis documented in the changelog and/or comments in the code.
