Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59926 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbbJKOYT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Oct 2015 10:24:19 -0400
Date: Sun, 11 Oct 2015 07:24:19 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v5 6/9] vfs: Copy should use file_out rather than file_in
Message-ID: <20151011142419.GE31867@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-7-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443634014-3026-7-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 30, 2015 at 01:26:50PM -0400, Anna Schumaker wrote:
> The way to think about this is that the destination filesystem reads the
> data from the source file and processes it accordingly.  This is
> especially important to avoid an infinate loop when doing a "server to
> server" copy on NFS.

And doesn't really matter without those.  Either way this looks good
enough and should be folded.
