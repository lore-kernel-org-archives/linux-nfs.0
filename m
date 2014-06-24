Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60105 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbaFXLxi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2014 07:53:38 -0400
Date: Tue, 24 Jun 2014 04:53:36 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 012/104] NFSd: Clean up helper __release_lock_stateid
Message-ID: <20140624115336.GB31935@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <1403189450-18729-13-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403189450-18729-13-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 19, 2014 at 10:49:18AM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Use filp_close() instead of open coding

filp_close does more than what's currently opencoded here:

 - file_count debug check which seems pointless but harmless
 - calling ->flush. This doesn't do much on nfs exportable filesystem
   except for exofs, which does dumb shit in it that should be removed,
   but the maintainer refuse.
 - call into dnotify, which we probably should be doing here.

> -static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
> +static void __release_lock_stateid(struct nfs4_lockowner *lo,
> +		struct nfs4_ol_stateid *stp)

But what's the point of explicitly passing the lock owner instead of
deriving it?

