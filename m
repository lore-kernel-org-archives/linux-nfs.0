Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34086 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146AbbKYSWI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2015 13:22:08 -0500
MIME-Version: 1.0
In-Reply-To: <5655EB40.8070508@oracle.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
	<20151123221430.32702.86114.stgit@manet.1015granger.net>
	<5653B606.3070700@talpey.com>
	<20151124065225.GB29141@infradead.org>
	<5654DC7A.7080807@oracle.com>
	<20151125090009.GA11255@infradead.org>
	<5655EB40.8070508@oracle.com>
Date: Wed, 25 Nov 2015 20:22:07 +0200
Message-ID: <CAJ3xEMgC5aa8pvvvs0y8O+h_WBk-em07gHvOgP=DFDrv4ydGAg@mail.gmail.com>
Subject: Re: Future of FMR support, was: Re: [PATCH v1 5/9] xprtrdma: Add
 ro_unmap_sync method for FMR
From: Or Gerlitz <gerlitz.or@gmail.com>
To: santosh shilimkar <santosh.shilimkar@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Tom Talpey <tom@talpey.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Sagi Grimberg <sagig@mellanox.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 25, 2015 at 7:09 PM, santosh shilimkar
<santosh.shilimkar@oracle.com> wrote:
>>> As already indicated to Sagi [1], RDS IB FR support is work in
>>> progress and I was hoping to get it ready for 4.5.

These are really good news! can you please elaborate a bit on the
design changes this move introduced in RDS?
