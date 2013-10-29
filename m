Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41571 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab3J2HgB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 03:36:01 -0400
Date: Tue, 29 Oct 2013 00:35:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Message-ID: <20131029073558.GA10889@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 10:57:26AM -0400, Anna Schumaker wrote:
> This patch adds in the SEEK operation used by clients doing an llseek on
> a file to find either hole or data sections in a file.  I'm faking the
> "allocated" status right now, since I haven't quite figured out how to
> tell if a range is allocated on disk yet.
> 
> This patch is missing correctly determining the "allocated" status of
> the HOLE / DATA range.  I expect I'll need to learn all about how fiemap
> works before properly setting these values.

What is the definition of allocated in this context?  Specificly how
does it different from meaning of allocated as used by SEEK_DATA?

Going out to fiemap is something we should absolutely avoid.

