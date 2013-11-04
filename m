Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39550 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749Ab3KDRFK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 12:05:10 -0500
Date: Mon, 4 Nov 2013 09:05:10 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Message-ID: <20131104170510.GB31499@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
 <20131029073558.GA10889@infradead.org>
 <526FB180.1060003@netapp.com>
 <20131029130721.GA32094@infradead.org>
 <20131029133006.GB29606@fieldses.org>
 <20131102134837.GA18961@infradead.org>
 <20131102143729.GA26983@fieldses.org>
 <20131102144107.GA28743@infradead.org>
 <20131104164658.GA4427@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131104164658.GA4427@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 04, 2013 at 11:46:58AM -0500, J. Bruce Fields wrote:
> Imagine it was me, if it helps.
> 
> The important thing is that we understand what should be fixed.

The important part is how someone got the idea for the pattern writing
and the weird ADBs from and why they believe they should overload a
single command for all of them.  And apparently reqular data writes as
well, even if I haven't found that part of the spec yet.

