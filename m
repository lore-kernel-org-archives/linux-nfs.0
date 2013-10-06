Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60759 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab3JFPaq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Oct 2013 11:30:46 -0400
Date: Sun, 6 Oct 2013 08:30:46 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] SQUASHME: pnfsd: no need for find_file in layout
 commit/return
Message-ID: <20131006153046.GB8801@infradead.org>
References: <5251140B.4000203@primarydata.com>
 <1381045472-30717-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381045472-30717-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 06, 2013 at 10:44:32AM +0300, Benny Halevy wrote:
> the nfs4_file can be found via the layout stateid.

Oh, here we go.  Really should be folded into the previous one to make
sense.

>  	/* Is this the first use of this layout ? */
>  	if (stid->sc_type != NFS4_LAYOUT_STID) {
> +		status = nfserr_bad_stateid;
> +		goto out;
>  	} else {

Given that you already have a goto out here there is no need for the
else clause.

