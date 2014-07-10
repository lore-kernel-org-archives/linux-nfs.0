Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:45711 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989AbaGJMno (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 08:43:44 -0400
Date: Thu, 10 Jul 2014 05:43:43 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 016/100] nfsd: always hold the fi_lock when bumping
 fi_access refcounts
Message-ID: <20140710124343.GB30941@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-17-git-send-email-jlayton@primarydata.com>
 <20140710085107.GA20292@infradead.org>
 <20140710082043.25418f69@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710082043.25418f69@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 08:20:43AM -0400, Jeff Layton wrote:
> Yes. We don't have to hold the lock when putting refcounts if we do.

So we can optimze the case where a reference is dropped but the file
stays around.  That sound reasonable.

