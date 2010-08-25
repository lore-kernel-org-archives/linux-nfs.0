Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51975 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082Ab0HYKxV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Aug 2010 06:53:21 -0400
Date: Wed, 25 Aug 2010 06:53:20 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Harry Edmon <harry@uw.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Odd problem with Stale NFS file handle - NFS v3 server under
 2.6.35.x
Message-ID: <20100825105320.GA17190@infradead.org>
References: <4C7407D2.1040304@uw.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C7407D2.1040304@uw.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Are you running xfs on this machine?  If so can you please try
this patch:

	http://git.kernel.org/?p=linux/kernel/git/dgc/xfsdev.git;a=commitdiff;h=4536f2ad8b330453d7ebec0746c4374eadd649b1

