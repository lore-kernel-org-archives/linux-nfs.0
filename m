Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:40295 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412Ab3KDUNX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 15:13:23 -0500
Date: Mon, 4 Nov 2013 12:13:20 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "Haynes, Tom" <Tom.Haynes@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Christoph Hellwig <hch@infradead.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131104201320.GA21884@infradead.org>
References: <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131102135238.GB18961@infradead.org>
 <5277CE23.6010207@netapp.com>
 <20131104170345.GA31499@infradead.org>
 <5277D80F.8050106@netapp.com>
 <20131104185309.GA14378@infradead.org>
 <3AC4ECC6-0496-4593-8791-92BCAD2567CC@oracle.com>
 <20131104191907.GA9337@infradead.org>
 <8EB0049A-9225-4C4A-8099-774B2EB48323@oracle.com>
 <1A74FF84-00E2-4C5F-A209-350792D2E0AE@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1A74FF84-00E2-4C5F-A209-350792D2E0AE@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 04, 2013 at 08:03:58PM +0000, Haynes, Tom wrote:
> Do you have an issue with READ_PLUS?
> 
> I.e., are you okay with that operation because the answer is not known beforehand?

The hole vs data part of it looks reasonable.  The whole ADH complex
looks a little fishy to me, but I will have to dig deeper into before
writing down a detailed critism.

But one very obvious question already comes up:  what data is supposed
to be returned when a client that doesn't suport 4.2 at all are doesn't
support ADHs reads a file that contains them.  From a quick glance it
seems a mapping from ADHs to flat blocks is possible, but such a mapping
should be specified in the standard.

> There was a strong consensus in the biweekly calls to merge all of the operations together into WRITE_PLUS.

Do you remember any arguments for it?  Also any rational for adding the
plain old data write to it?

