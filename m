Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60036 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753690Ab3KBNsk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Nov 2013 09:48:40 -0400
Date: Sat, 2 Nov 2013 06:48:37 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Message-ID: <20131102134837.GA18961@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
 <20131029073558.GA10889@infradead.org>
 <526FB180.1060003@netapp.com>
 <20131029130721.GA32094@infradead.org>
 <20131029133006.GB29606@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131029133006.GB29606@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 09:30:06AM -0400, J. Bruce Fields wrote:
> I haven't read these parts of the spec yet at all....

Btw, is there a way do to something like a git blame for the spec?  I'd
really love to confront people personally with some of the odd bits they
came up with.

