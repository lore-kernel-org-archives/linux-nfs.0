Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35969 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbaIISNC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 14:13:02 -0400
Date: Tue, 9 Sep 2014 11:13:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna.Schumaker@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] NFSD: Add ALLOCATE and DEALLOCATE support
Message-ID: <20140909181302.GA17155@infradead.org>
References: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry to hijack this thread, but talking about 4.2 server features, did
anyone into looking into implementing the change_attr_type attribute,
which should be fairly low hanging fruit?

Also someone with interest in btrfs might want to look into implementing
the space_freed attribute with a call into the filesystem.

