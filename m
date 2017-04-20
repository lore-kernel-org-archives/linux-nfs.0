Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35317 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S971638AbdDTSLZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Apr 2017 14:11:25 -0400
Received: by mail-io0-f180.google.com with SMTP id r16so77440517ioi.2
        for <linux-nfs@vger.kernel.org>; Thu, 20 Apr 2017 11:11:24 -0700 (PDT)
Date: Thu, 20 Apr 2017 12:11:16 -0600
From: Jens Axboe <axboe@kernel.dk>
To: Jan Kara <jack@suse.cz>
Cc: linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        Petr Vandrovec <petr@vandrovec.name>,
        linux-nilfs@vger.kernel.org, cluster-devel@redhat.com,
        osd-dev@open-osd.org, codalist@coda.cs.cmu.edu,
        linux-afs@lists.infradead.org, ecryptfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        lustre-devel@lists.lustre.org
Subject: Re: [PATCH 0/25 v3] fs: Convert all embedded bdis into separate ones
Message-ID: <20170420181115.GA22378@kernel.dk>
References: <20170412102449.16901-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170412102449.16901-1-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 12 2017, Jan Kara wrote:
> Hello,
> 
> this is the third revision of the patch series which converts all embedded
> occurences of struct backing_dev_info to use standalone dynamically allocated
> structures. This makes bdi handling unified across all bdi users and generally
> removes some boilerplate code from filesystems setting up their own bdi. It
> also allows us to remove some code from generic bdi implementation.
> 
> The patches were only compile-tested for most filesystems (I've tested
> mounting only for NFS & btrfs) so fs maintainers please have a look whether
> the changes look sound to you.
> 
> This series is based on top of bdi fixes that were merged into linux-block
> git tree into for-next branch. I have pushed out the result as a branch to
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs.git bdi
> 
> Since all patches got reviewed by Christoph, can you please pick them up Jens?
> Thanks!

Yep, picked up for 4.12. Thanks Jan!

-- 
Jens Axboe

