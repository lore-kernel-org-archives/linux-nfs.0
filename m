Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:56579 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758440Ab3JKT4J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Oct 2013 15:56:09 -0400
Date: Fri, 11 Oct 2013 12:56:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 10/49] pnfsd: use sbid hash table to map
 super_blocks to devid major identifiers
Message-ID: <20131011195608.GA18634@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220831-13136-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220831-13136-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 02:40:31PM -0400, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@panasas.com>

This is entirely unessecary.  Just make sure all layouts set the sbid
field in getdevicelist to the s_dev value of the filesystem and you
can just use user_get_super.

