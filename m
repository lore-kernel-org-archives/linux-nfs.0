Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58445 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756641AbaF3Mvn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 08:51:43 -0400
Date: Mon, 30 Jun 2014 05:51:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 000/117] nfsd: eliminate the client_mutex
Message-ID: <20140630125142.GA32089@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm pretty happy with what's the first 25 patches in this version
with all the review comments addressed, so as far as I'm concerned
these are ready for for-next.  Does anyone else plan to do a review
as well?

I'll try to get to the locking changes as well soon, but I've got some
work keeping me fairly busy at the moment.  I guess it wasn't easily
feasible to move the various stateid refcounting to before the major
locking changes?

Btw, do you have any benchrmarks showing the improvements of the new
locking scheme?
