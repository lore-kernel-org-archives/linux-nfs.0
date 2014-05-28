Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:45273 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbaE1IJp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 04:09:45 -0400
Date: Wed, 28 May 2014 01:09:45 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 41/52] nfsd4: turn off zero-copy-read in exotic cases
Message-ID: <20140528080945.GA6797@infradead.org>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
 <1400787148-25941-42-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1400787148-25941-42-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 22, 2014 at 03:32:16PM -0400, J. Bruce Fields wrote:
> Later patches handle those "exotic compounds", this one just makes sure
> zero-copy is turned off in those cases.

How did you test these exotic compounds?

