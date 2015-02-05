Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50741 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbbBEOLj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 09:11:39 -0500
Date: Thu, 5 Feb 2015 06:11:38 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna.Schumaker@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/4] NFSD: nfsd4_encode_read() should encode eof and
 maxcount
Message-ID: <20150205141138.GB4522@infradead.org>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1422477777-27933-2-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1422477777-27933-2-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The subject line should include readv instead of read as well, shouldn't
it?
