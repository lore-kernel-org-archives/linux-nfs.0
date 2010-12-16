Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:41022 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289Ab0LPXQ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 18:16:29 -0500
Date: Thu, 16 Dec 2010 18:16:26 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Ric Wheeler <ricwheeler@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Steve Dickson <SteveD@redhat.com>,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/31] NFS XDR clean up for 2.6.38
Message-ID: <20101216231626.GA24880@infradead.org>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
 <4D0A6503.7010901@RedHat.com>
 <20101216230524.GA16760@infradead.org>
 <4D0A9D5A.1070708@gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D0A9D5A.1070708@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 16, 2010 at 06:14:34PM -0500, Ric Wheeler wrote:
> This is not us trying to block anything, just do an orderly testing of changes.
> 
> Why do three "waves" of pNFS related changes and refactor code all at once?

Because some forces seem to force pnfs into the kernel despite neither
beeing ready nor overly useful.  If you look at the userbase of the
Linux NFS client a robust XDR encode/decoder without buffer overflows is
a lot more important than a partially working pNFS client.
