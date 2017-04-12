Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:42514 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752546AbdDLIJd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Apr 2017 04:09:33 -0400
Date: Wed, 12 Apr 2017 01:09:28 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        Petr Vandrovec <petr@vandrovec.name>,
        linux-nilfs@vger.kernel.org, cluster-devel@redhat.com,
        osd-dev@open-osd.org, codalist@coda.cs.cmu.edu,
        linux-afs@lists.infradead.org, ecryptfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        lustre-devel@lists.lustre.org
Subject: Re: [PATCH 04/25] fs: Provide infrastructure for dynamic BDIs in
 filesystems
Message-ID: <20170412080928.GD9830@infradead.org>
References: <20170329105623.18241-1-jack@suse.cz>
 <20170329105623.18241-5-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170329105623.18241-5-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	if (sb->s_iflags & SB_I_DYNBDI) {
> +		bdi_put(sb->s_bdi);
> +		sb->s_bdi = &noop_backing_dev_info;

At some point I'd really like to get rid of noop_backing_dev_info and
have a NULL here..

Otherwise this looks fine..

Reviewed-by: Christoph Hellwig <hch@lst.de>
