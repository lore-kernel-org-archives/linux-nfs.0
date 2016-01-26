Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:37998 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932284AbcAZRAZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2016 12:00:25 -0500
Date: Tue, 26 Jan 2016 09:00:21 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Atchley, Scott" <atchleyes@ornl.gov>,
        "lsf-pc@lists.linux-foundation.org"
	<lsf-pc@lists.linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [LSF/MM TOPIC] Remote access to pmem on storage targets
Message-ID: <20160126170021.GA21672@infradead.org>
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com>
 <5FD20017-B588-42E6-BBDA-2AA8ABDBA42B@ornl.gov>
 <D0C5C0B9-A1A2-4428-B3CA-7BBCC5BEF10D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D0C5C0B9-A1A2-4428-B3CA-7BBCC5BEF10D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 26, 2016 at 10:29:35AM -0500, Chuck Lever wrote:
> As I understand it, NVMf devices look like local devices.
> NVMf devices need globally unique naming to enable safe use
> with pNFS and other remote storage access protocols.

NVMe provides global uniqueue identifiers similar to SCSI, and in fact
there is even a standardised mapping to SCSI.  The current SCSI layout
draft will work fine with both multi ported PCIe NVMe devices as well
as future fabrics devices.
