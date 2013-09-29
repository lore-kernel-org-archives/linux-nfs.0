Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59909 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab3I2Lmo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Sep 2013 07:42:44 -0400
Date: Sun, 29 Sep 2013 04:42:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Lev Solomonov <solo@primarydata.com>,
        Idan Kedar <idank@primarydata.com>,
        Nadav Shemer <nadav@primarydata.com>
Subject: Re: [PATCH RFC v0 0/49] pnfsd-dlm
Message-ID: <20130929114240.GA25750@infradead.org>
References: <52447EA0.7070004@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 02:36:16PM -0400, Benny Halevy wrote:
> The following patchset implements an extension to nfsd
> providing a complete minimal pnfs server exporting
> DLM-based clustered file systems such as GFS2 or OCFS2.

Does this actually buy us anything by now?  Last time I saw numbers for
this implementation it was slower than an active/passive setup over
those filesystem due to the way their cluster locking works.

