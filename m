Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52011 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199Ab3JaQEn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Oct 2013 12:04:43 -0400
Date: Thu, 31 Oct 2013 09:04:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Message-ID: <20131031160440.GA30108@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Btw, I just noticed that current nfs mainline fails xfstests 286 which
test SEEK_DATA/SEEK_HOLE.   That sounds like a useful test case for your
patches.

