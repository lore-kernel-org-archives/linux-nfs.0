Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [198.137.202.9] ([198.137.202.9]:55358 "EHLO
	bombadil.infradead.org" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933849AbcCOIQR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2016 04:16:17 -0400
Date: Tue, 15 Mar 2016 01:15:25 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        bfields@fieldses.org, hch@infradead.org
Subject: Re: [PATCH v3 4/3] vfs_copy_range() test program
Message-ID: <20160315081525.GA2592@infradead.org>
References: <1457474158-16050-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1457474158-16050-5-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1457474158-16050-5-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Can you try to wire up varius corner case tests in xfstests, please?

We have 123 clone tests in the generic xfstests group, plus a lot of
btrfs and xfs specific ones.  It would be great to have at least the
most important ones ported to test copy as well.
