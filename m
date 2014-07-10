Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54264 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436AbaGJNBG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 09:01:06 -0400
Date: Thu, 10 Jul 2014 06:01:05 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 011/100] nfsd: refactor nfs4_file_get_access and
 nfs4_file_put_access
Message-ID: <20140710130105.GA14741@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-12-git-send-email-jlayton@primarydata.com>
 <20140710075920.GA6226@infradead.org>
 <20140710073214.5621293f@tlielax.poochiereds.net>
 <20140710113523.GA17814@infradead.org>
 <20140710084922.6899fdf2@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710084922.6899fdf2@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 08:49:22AM -0400, Jeff Layton wrote:
> gets are always done with the lock held. puts do an atomic_dec_and_lock
> or are done with the lock held. I don't see how that's racy...

Yeah, as long as the atomic_read for the other fd is done under the lock
it should be fine in the end.

