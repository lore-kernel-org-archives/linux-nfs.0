Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:39900 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751521AbcCYSEY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Mar 2016 14:04:24 -0400
Date: Fri, 25 Mar 2016 19:04:22 +0100
From: Christoph Hellwig <hch@lst.de>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfds: Fix NFSD_MDS_PR_KEY on 32-bit by adding ULL
	postfix
Message-ID: <20160325180422.GA15549@lst.de>
References: <1458902831-24673-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1458902831-24673-1-git-send-email-geert@linux-m68k.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks fine, thanks!

Reviewed-by: Christoph Hellwig <hch@lst.de>
