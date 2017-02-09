Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35772 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751693AbdBIND5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Feb 2017 08:03:57 -0500
Date: Thu, 9 Feb 2017 13:12:12 +0100
From: Jan Kara <jack@suse.cz>
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: Jan Kara <jack@suse.cz>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-nilfs@vger.kernel.org" <linux-nilfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "ecryptfs@vger.kernel.org" <ecryptfs@vger.kernel.org>,
        "codalist@coda.cs.cmu.edu" <codalist@TELEMANN.coda.cs.cmu.edu>,
        Christoph Hellwig <hch@infradead.org>,
        "cluster-devel@redhat.com" <cluster-devel@redhat.com>,
        "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
        "osd-dev@open-osd.org" <osd-dev@open-osd.org>,
        "v9fs-developer@lists.sourceforge.net"
        <v9fs-developer@lists.sourceforge.net>,
        "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
        Petr Vandrovec <petr@vandrovec.name>,
        "linux-afs@lists.infradead.org" <linux-afs@lists.infradead.org>,
        "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>,
        "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] [PATCH 04/24] fs: Provide infrastructure for
 dynamic        BDIs in filesystems
Message-ID: <20170209121212.GD16825@quack2.suse.cz>
References: <20170202173422.3240-1-jack@suse.cz>
 <20170202173422.3240-5-jack@suse.cz>
 <C01BF300-AD67-4A3E-810F-AAB2EEB90B97@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <C01BF300-AD67-4A3E-810F-AAB2EEB90B97@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > @@ -1249,6 +1254,50 @@ mount_fs(struct file_system_type *type, int flags, const char *name, void *data)
> > }
> > 
> > /*
> > + * Setup private BDI for given superblock. I gets automatically cleaned up
> 
> (typo) s/I/It/
> 
> Looks fine otherwise.

Thanks, fixed.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
