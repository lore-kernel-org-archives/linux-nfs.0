Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49566 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbGMHkJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 03:40:09 -0400
Date: Mon, 13 Jul 2015 00:40:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Zach Brown <zab@zabbo.net>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 0/7] nfs: minor cleanups and NFSv42 CLONE support
Message-ID: <20150713074008.GA23338@infradead.org>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
 <20150713065632.GA26245@infradead.org>
 <CAKVebiUnoFkp-q3VypGMqojvGF1MAAKLLY0PqABzD7DHq0w7Pw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiUnoFkp-q3VypGMqojvGF1MAAKLLY0PqABzD7DHq0w7Pw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2015 at 03:30:56PM +0800, Peng Tao wrote:
> I wasn't able to find XFS clone implementation in upstream kernel. Can
> you please give a point to it so I can take a look?

Hi Peng,

it's not merged yet, I just mentioned it because it follows the btrfs
lead:

	http://oss.sgi.com/archives/xfs/2015-06/msg00407.html
