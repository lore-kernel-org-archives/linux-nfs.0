Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58152 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbaESPhk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 11:37:40 -0400
Date: Mon, 19 May 2014 08:37:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 00/18] nfs: support multiple requests per page
Message-ID: <20140519153739.GA1163@infradead.org>
References: <1400169417-28245-1-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1400169417-28245-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 15, 2014 at 11:56:39AM -0400, Weston Andros Adamson wrote:
> This patchset changes the read and write paths to be more flexible in dealing
> with requests that are not page aligned. Until now there was a 1:1 mapping
> of struct nfs_page (referred to as "nfs requests") to struct page, which

Any chance you could throw in a rename nfs_page to nfs_request patch
at the end of the series?  The nfs_page name is highly confusing,
and gets even more so with the series.

