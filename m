Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:55325 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbbGMG4i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 02:56:38 -0400
Date: Sun, 12 Jul 2015 23:56:32 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Zach Brown <zab@zabbo.net>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 0/7] nfs: minor cleanups and NFSv42 CLONE support
Message-ID: <20150713065632.GA26245@infradead.org>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Peng,

please do not add another different ioctl.  I would much prefer to bring
the yscall forward.  Alternatively please follow the btrfs ioctl, which
XFS has been picking up as well.

