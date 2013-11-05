Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41356 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806Ab3KEBDe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 20:03:34 -0500
Date: Mon, 4 Nov 2013 17:03:32 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Thomas Haynes <loghyr@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Bryan Schumaker <bjschuma@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Message-ID: <20131105010332.GA32189@infradead.org>
References: <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
 <20131029073558.GA10889@infradead.org>
 <526FB180.1060003@netapp.com>
 <20131029130721.GA32094@infradead.org>
 <20131029133006.GB29606@fieldses.org>
 <20131102134837.GA18961@infradead.org>
 <20131102143729.GA26983@fieldses.org>
 <20131102144107.GA28743@infradead.org>
 <20131104164658.GA4427@fieldses.org>
 <5BAB86A3-045A-4CA9-A08F-7B0E38DBAC7D@excfb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5BAB86A3-045A-4CA9-A08F-7B0E38DBAC7D@excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 04, 2013 at 01:56:39PM -0800, Thomas Haynes wrote:
> Nah, most likely me, no imagination needed.
> 
> We were also looking at bringing larger WRITEs during 4.3 and I wanted
> to have WRITE_PLUS already in place for that.

What exactly does a WRITE PLUS with various non-related overloads in 4.2
buy you for introducing large writes in 4.3?
