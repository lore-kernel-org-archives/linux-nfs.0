From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [nfsv4] layoutcommits and file layout
Date: Thu, 16 Dec 2010 18:07:07 -0500
Message-ID: <20101216230707.GB16760@infradead.org>
References: <978693366.32.1292516428080.JavaMail.root@thunderbeast.private.linuxbox.com>
 <1740153586.34.1292516481789.JavaMail.root@thunderbeast.private.linuxbox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fred Isaman <iisaman@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	nfsv4@ietf.org, Boaz Harrosh <bharrosh@panasas.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56460 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119Ab0LPXHL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 18:07:11 -0500
In-Reply-To: <1740153586.34.1292516481789.JavaMail.root-DQa+Qhn4Z593Hjf6844flrbbgpPoC6wPvwx5bNz670MAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 16, 2010 at 11:21:21AM -0500, Matt W. Benjamin wrote:
> Hi,
> 
> We have a files implementation which wants to receive LAYOUTCOMMIT when a client is finished with a layout.  It was my clear understanding from rfc5661 that we could expect this behavior.

Care to post it to the list?

