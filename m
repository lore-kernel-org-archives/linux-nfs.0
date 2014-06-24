Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41966 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbaFXMGn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2014 08:06:43 -0400
Date: Tue, 24 Jun 2014 05:06:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 011/104] NFSd: Lock owners are not per open stateid
Message-ID: <20140624120642.GA11055@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <1403189450-18729-12-git-send-email-jlayton@primarydata.com>
 <20140624115058.GA31935@infradead.org>
 <20140624080426.75799943@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140624080426.75799943@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 24, 2014 at 08:04:26AM -0400, Jeff Layton wrote:
> Yeah, I was thinking about that last night. I think the parts that could
> be broken out are:
> 
> - the change to multiple stateids per lockowner

this one definitively should as it is a significant change in behavior.

The second batch that seems easily separatable is the improvements
of the client lookup and caching, which includes a few patches.

> - moving some of the fields into nfs4_stid
> - adding refcounting for stateids and stateowners and fixing the
>   relationships between them

These are indeed deeply interwinded with the locking changes.  I still
think having them earlier would be useful, but if it's too much work
we'll have to live with what we get.

