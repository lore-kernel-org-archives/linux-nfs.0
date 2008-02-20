From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: flush signals before taking down callback thread
Date: Wed, 20 Feb 2008 10:10:13 -0500
Message-ID: <1203520213.8620.15.camel@heimdal.trondhjem.org>
References: <1203443495-7854-1-git-send-email-jlayton@redhat.com>
	 <20080219222226.GA10656@infradead.org>
	 <1203461010.13265.12.camel@heimdal.trondhjem.org>
	 <20080220090110.5658c78e@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:53865 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303AbYBTPKT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2008 10:10:19 -0500
In-Reply-To: <20080220090110.5658c78e-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-20 at 09:01 -0500, Jeff Layton wrote:
> I did a bit of smoke testing on that patch this morning and just sent
> it out to the list. The only problem is that that patch depends on a
> couple of other patches currently in Bruce's tree and that are slated
> for 2.6.26. It might be reasonable in the interim to go ahead and take
> the patch to flush_signals() in the existing code.

OK. I'll push that patch to Linus some time in the next few days.

Trond

