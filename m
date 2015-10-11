Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59317 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606AbbJKOWe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Oct 2015 10:22:34 -0400
Date: Sun, 11 Oct 2015 07:22:33 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v5 5/9] vfs: Copy shouldn't forbid ranges inside the same
 file
Message-ID: <20151011142233.GC31867@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-6-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443634014-3026-6-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Needs to be folded.
