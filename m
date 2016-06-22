Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54969 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbcFVPsl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 11:48:41 -0400
Date: Wed, 22 Jun 2016 08:48:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 01/12] NFS: Don't flush caches for a getattr that
 races with writeback
Message-ID: <20160622154841.GA815@infradead.org>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series (or rather your testing branch, which should have the fixups
later in the thread already folded in) causes various xfstests
regressions:

generic/010 generic/020 generic/037 generic/062
generic/100 generic/247 generic/249 generic/337

They seems to be a mix of xattrs, direct I/O consistency and maybe
a few other issues.

This was a auto group run against a Linux server running xfs using
NFSv4.0.
