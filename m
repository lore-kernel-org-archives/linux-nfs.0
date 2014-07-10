Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36818 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989AbaGJLfX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 07:35:23 -0400
Date: Thu, 10 Jul 2014 04:35:23 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 011/100] nfsd: refactor nfs4_file_get_access and
 nfs4_file_put_access
Message-ID: <20140710113523.GA17814@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-12-git-send-email-jlayton@primarydata.com>
 <20140710075920.GA6226@infradead.org>
 <20140710073214.5621293f@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710073214.5621293f@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 07:32:14AM -0400, Jeff Layton wrote:
> So, you're correct that we never take an fi_access reference for O_RDWR,
> which is why the array doesn't have a slot for it:
> 
>         atomic_t                fi_access[2];
> 
> ...it's tracked by the union of the O_RDONLY and O_WRONLY counters.

Which will be racy as long we try to use an atomic_t and not a proper
lock over access to all of fi_access.

I'm still trying to understand why we even need fi_access and can't just
use the file references directly, though.

