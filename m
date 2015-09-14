Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:55656 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754162AbbINL4k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2015 07:56:40 -0400
Subject: Re: [PATCH 00/39] drop null test before destroy functions
To: Julia Lawall <Julia.Lawall@lip6.fr>, kernel-janitors@vger.kernel.org
References: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: iommu@lists.linux-foundation.org, dccp@vger.kernel.org,
        dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org,
        ecryptfs@vger.kernel.org, dmaengine@vger.kernel.org,
        sergey.senozhatsky@gmail.com, Dan Williams <dan.j.williams@intel.com>,
        cluster-devel@redhat.com, intel-wired-lan@lists.osuosl.org,
        Mitch Williams <mitch.a.williams@intel.com>,
        John Ronciak <john.ronciak@intel.com>,
        Matthew Vick <matthew.vick@intel.com>,
        Don Skidmore <donald.c.skidmore@intel.com>,
        Carolyn Wyborny <carolyn.wyborny@intel.com>,
        Shannon Nelson <shannon.nelson@intel.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
        netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
        linux-btrfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
        linux-usb@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-rdma@vger.kernel.org, devel@driverdev.osuosl.org,
        HPDD-discuss@ml01.01.org, linux-bcache@vger.kernel.org,
        drbd-user@lists.linbit.com, ocfs2-devel@oss.oracle.com,
        kvm@vger.kernel.org, ceph-devel@vger.kernel.org,
        Chao Yu <chao2.yu@samsung.com>, linux-f2fs-devel@lists.sourceforge.net
From: SF Markus Elfring <elfring@users.sourceforge.net>
Message-ID: <55F6B59A.4040104@users.sourceforge.net>
Date: Mon, 14 Sep 2015 13:55:06 +0200
MIME-Version: 1.0
In-Reply-To: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
Content-Type: text/plain; charset=iso-8859-15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Recent commits to kernel/git/torvalds/linux.git have made the following
> functions able to tolerate NULL arguments:
>
> kmem_cache_destroy (commit 3942d29918522)
> mempool_destroy (commit 4e3ca3e033d1)
> dma_pool_destroy (commit 44d7175da6ea)

How do you think about to extend an other SmPL script?

Related topic:
scripts/coccinelle/free: Delete NULL test before freeing functions
https://systeme.lip6.fr/pipermail/cocci/2015-May/001960.html
https://www.mail-archive.com/cocci@systeme.lip6.fr/msg01855.html


> If these changes are OK, I will address the remainder later.

Would anybody like to reuse my general SmPL approach for similar source
code clean-up?

Regards,
Markus
