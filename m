Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43268 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbcC1Xs2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Mar 2016 19:48:28 -0400
Date: Mon, 28 Mar 2016 19:48:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfds: Fix NFSD_MDS_PR_KEY on 32-bit by adding ULL postfix
Message-ID: <20160328234825.GA27902@fieldses.org>
References: <1458902831-24673-1-git-send-email-geert@linux-m68k.org>
 <20160325180422.GA15549@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160325180422.GA15549@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 25, 2016 at 07:04:22PM +0100, Christoph Hellwig wrote:
> Looks fine, thanks!
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks, applying for 4.6.--b.
