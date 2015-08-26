Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41082 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756541AbbHZNL5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 09:11:57 -0400
Date: Wed, 26 Aug 2015 06:11:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH-RFC-RESEND 0/9] NFS/NFSD: add NFSv42 CLONE operation
 support
Message-ID: <20150826131156.GA9948@infradead.org>
References: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 04:16:41PM +0800, Peng Tao wrote:
> 2. vfs_file_clone_range() does not expect file systems to do data copy, and thus
> no rw_verify_area() required.

While there is no physical copy involved, the data logically is copied from
file A to file B.  So we still need all the checks from rw_verify_area.

