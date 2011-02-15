Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:46040 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754670Ab1BOMJ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 07:09:29 -0500
Date: Tue, 15 Feb 2011 07:09:24 -0500
From: Jim Rees <rees@umich.edu>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/6] nfsd4: split up nfsd_break_deleg_cb
Message-ID: <20110215120924.GA5756@merit.edu>
References: <1297227351-15365-1-git-send-email-bfields@redhat.com>
 <1297227351-15365-2-git-send-email-bfields@redhat.com>
 <20110209050118.GA2485@infradead.org>
 <20110209151402.GA13624@pad.home.fieldses.org>
 <20110209162838.GA21056@merit.edu>
 <20110215111404.GA12517@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110215111404.GA12517@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Christoph Hellwig wrote:

  The linux styles of most indent-like programs are utter garbage.  If you
  want Linux style use the scripts/Lindent script in the source tree.  It
  still has a few quirks, like stupid ways to split overly long lines, but
  generally does a reasonable job.

I'll give that a try, thanks.  Someone should fix "indent -linux", or at
least its man page.
