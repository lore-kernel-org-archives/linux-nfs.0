Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:56755 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272Ab1HKGWK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 02:22:10 -0400
From: <tao.peng@emc.com>
To: <hch@infradead.org>
CC: <torvalds@linux-foundation.org>, <rdunlap@xenotime.net>,
        <bergwolf@gmail.com>, <Trond.Myklebust@netapp.com>,
        <linux-raid@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Date: Thu, 11 Aug 2011 02:21:17 -0400
Subject: RE: Linux 3.1-rc1 (nfs/pnfs and drivers/md)
Message-ID: <F19688880B763E40B28B2B462677FBF805BF0EACC4@MX09A.corp.emc.com>
References: <CA+55aFwkJdyEpyNY64aAQ5ChrPZ8Kvx9iRUwy1J6_SRaxoN=zA@mail.gmail.com>
 <20110810122304.96b8be67.rdunlap@xenotime.net>
 <CA+a=Yy5izxiyvW5eYiWuute9E1vXwNTj4frdzNeEwsLDrszesg@mail.gmail.com>
 <20110810175829.a834d80f.rdunlap@xenotime.net>
 <CA+55aFzcSLrhkexEn=J7BN8F3P3Vy+EAjwgGwMQPdeoYoQG+Bw@mail.gmail.com>
 <F19688880B763E40B28B2B462677FBF805BF0EAC8A@MX09A.corp.emc.com>
 <20110811060633.GA11654@infradead.org>
In-Reply-To: <20110811060633.GA11654@infradead.org>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Christoph Hellwig [mailto:hch@infradead.org]
> Sent: Thursday, August 11, 2011 2:07 PM
> To: Peng, Tao
> Cc: torvalds@linux-foundation.org; rdunlap@xenotime.net; bergwolf@gmail.com;
> Trond.Myklebust@netapp.com; linux-raid@vger.kernel.org;
> linux-kernel@vger.kernel.org; linux-nfs@vger.kernel.org
> Subject: Re: Linux 3.1-rc1 (nfs/pnfs and drivers/md)
> 
> Note that the object layout also effectively needs the block layer.
> 
That is taken care of by PNFS_OBJLAYOUT depending on SCSI_OSD_ULD.

The dependency chain for PNFS_OBJLAYOUT on BLOCK is:
PNFS_OBJLAYOUT-> SCSI_OSD_ULD -> SCSI_OSD_INITIATOR -> SCSI-> BLOCK

With the patch, if CONFIG_BLOCK is not set, pnfs file layout can still be built.

Thanks,
Tao

