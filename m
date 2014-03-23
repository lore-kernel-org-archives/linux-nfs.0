Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46275 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbaCWGvy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Mar 2014 02:51:54 -0400
Date: Sat, 22 Mar 2014 23:51:54 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 23/50] nfsd4: "backfill" using write_bytes_to_xdr_buf
Message-ID: <20140323065154.GD24465@infradead.org>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
 <1395537141-10389-24-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1395537141-10389-24-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good, but shouldn't there be an abstract function to skip writing
into an XDR buf instead of the pointer increment as well?

I wonder if the XDR buf internal should even be entirely hidden to the
consummers and it should only be accessed through procedural interfaces?

