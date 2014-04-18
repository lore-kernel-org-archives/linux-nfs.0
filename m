Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44341 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227AbaDRNr0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 09:47:26 -0400
Date: Fri, 18 Apr 2014 06:47:25 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFSD: Don't set default ACL if there are no ACE
 entries
Message-ID: <20140418134725.GA30815@infradead.org>
References: <534FCD13.303@gmail.com>
 <20140417143634.GA20857@infradead.org>
 <5350A0A2.1020401@gmail.com>
 <20140418121920.GD18612@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140418121920.GD18612@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2014 at 08:19:20AM -0400, J. Bruce Fields wrote:
> I thought Christoph's suggestion was to actually call ->set_acl with a
> NULL ACL?  Does that turn out to be unnecessary?

It's a no-op if there wasn't a previous ACL on the inode, but if there
was it needs to be removed by passing the NULL acl argument.

