Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42536 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754878Ab3J2Msg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 08:48:36 -0400
Date: Tue, 29 Oct 2013 05:48:36 -0700
From: Hellwig Christoph <hch@infradead.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Hellwig Christoph <hch@infradead.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFS: Allow for asynchronous WRITE_PLUS calls
Message-ID: <20131029124836.GA13482@infradead.org>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
 <1382972418-2249-3-git-send-email-bjschuma@netapp.com>
 <20131029073943.GD10889@infradead.org>
 <BF996CAD-1032-4434-A538-B678D047884B@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BF996CAD-1032-4434-A538-B678D047884B@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 12:44:50PM +0000, Myklebust, Trond wrote:
> It exists because the server vendors were worried that operations such as preallocation and/or hole punching can take a more or less unbounded amount of time due to the 64-bit size. By using an (optional) callback method, the server can free up the RPC slot that would otherwise be kept waiting in the synchronous case.

Must be some horried filesystems on those vendors servers.  Both
operations should be O(nr_extents), where nr_extents should be extremely
low for the preallocation and still reasonably low for hole punches,
although users control the allocastion pattern.

There's a reason why these aren't aio operations locally either.

