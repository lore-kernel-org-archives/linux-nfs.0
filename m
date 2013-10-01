Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38981 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab3JANhk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Oct 2013 09:37:40 -0400
Date: Tue, 1 Oct 2013 06:37:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 43/49] pnfsd: release state lock around iput in
 put_nfs4_file
Message-ID: <20131001133739.GA13149@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220968-14669-1-git-send-email-bhalevy@primarydata.com>
 <20130929121903.GF21083@infradead.org>
 <524ACEA9.1040304@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <524ACEA9.1040304@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 01, 2013 at 04:31:21PM +0300, Benny Halevy wrote:
> So the reason not to hold it is that the nfs state lock is global to the
> server and blocks all state modifying operations such as:
> open, close, lock, clientid, session operations, etc.

While not really related to this patch: what's the reason it's not
split?  The way nfsd works there should be almost no state that isn't
per-export.

