Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47946 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193AbbCQKhi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Mar 2015 06:37:38 -0400
Date: Tue, 17 Mar 2015 03:37:36 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSv4.1: Don't cache deviceids that have no
 notifications
Message-ID: <20150317103736.GA31940@infradead.org>
References: <1425931503-37261-1-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-2-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-3-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-4-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-5-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1425931503-37261-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 09, 2015 at 04:05:03PM -0400, Trond Myklebust wrote:
> The spec says that once all layouts that reference a given deviceid
> have been returned, then we are only allowed to continue to cache
> the deviceid if the metadata server supports notifications.

This causes massive performance issues for object and block layout
servers where a GETDEVICEINFO (or rather the client processing of it)
is expensive.  Also it increases the deadlock potential as the
GETDEVICEINFO generally isn't safe for writeback under memory pressure
(and yes, we'll need more fixes in that area).

I've also filed an errata a while ago to update the language in the spec
in this area to be consistent and not enforce this behavior:

http://www.rfc-editor.org/errata_search.php?rfc=5661&eid=4119

I think the right fix is to have a shrinker that allows the nfs client
to retire unused devices on a lru basis under memory pressure.
