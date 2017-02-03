Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:44457 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751252AbdBCSeB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2017 13:34:01 -0500
Date: Fri, 3 Feb 2017 10:31:56 -0800
From: Liu Bo <bo.li.liu@oracle.com>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        linux-block@vger.kernel.org, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, Petr Vandrovec <petr@vandrovec.name>,
        linux-nilfs@vger.kernel.org, cluster-devel@redhat.com,
        osd-dev@open-osd.org, codalist@TELEMANN.coda.cs.cmu.edu,
        linux-afs@lists.infradead.org, ecryptfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        lustre-devel@lists.lustre.org
Subject: Re: [PATCH 04/24] fs: Provide infrastructure for dynamic BDIs in
 filesystems
Message-ID: <20170203183155.GA30842@localhost.localdomain>
Reply-To: bo.li.liu@oracle.com
References: <20170202173422.3240-1-jack@suse.cz>
 <20170202173422.3240-5-jack@suse.cz>
 <20170202192827.GF6550@localhost.localdomain>
 <20170203135042.GB5844@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170203135042.GB5844@quack2.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 03, 2017 at 02:50:42PM +0100, Jan Kara wrote:
> On Thu 02-02-17 11:28:27, Liu Bo wrote:
> > Hi,
> > 
> > On Thu, Feb 02, 2017 at 06:34:02PM +0100, Jan Kara wrote:
> > > Provide helper functions for setting up dynamically allocated
> > > backing_dev_info structures for filesystems and cleaning them up on
> > > superblock destruction.
> > 
> > Just one concern, will this cause problems for multiple superblock cases
> > like nfs with nosharecache?
> 
> Can you ellaborate a bit? I've looked for a while what nfs with
> nosharecache does but I didn't see how it would influence anything with
> bdis...

Oh, I missed that bdi_seq was static, then it should be fine.

(I was worried about that nfs with nosharecache would have multiple
superblocks and if each superblock has a bdi using the same bdi name,
nfs-xx.)

Thanks for the reply.

Thanks,

-liubo
