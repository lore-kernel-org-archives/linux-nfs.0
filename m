Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:49832 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752414AbbLNQeF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Dec 2015 11:34:05 -0500
Date: Mon, 14 Dec 2015 17:34:03 +0100
From: Christoph Hellwig <hch@lst.de>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, viro@zeniv.linux.org.uk,
        tao.peng@primarydata.com, jeff.layton@primarydata.com,
        bfields@fieldses.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 2/4] vfs: pull btrfs clone API to vfs layer
Message-ID: <20151214163403.GA12687@lst.de>
References: <1449143992-7415-1-git-send-email-hch@lst.de> <1449143992-7415-3-git-send-email-hch@lst.de> <20151209204033.GB10582@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151209204033.GB10582@birch.djwong.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 09, 2015 at 12:40:33PM -0800, Darrick J. Wong wrote:
> I tried this patch series on ppc64 (w/ 32-bit powerpc userland) and I think
> it needs to fix up the compat ioctl to make the vfs call...

Might need a proper signoff for Al, unless he wants to directly fold it..
