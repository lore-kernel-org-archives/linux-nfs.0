Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:40985 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbbALMdz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2015 07:33:55 -0500
Date: Mon, 12 Jan 2015 13:33:51 +0100
From: Christoph Hellwig <hch@lst.de>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@fb.com>,
        David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org
Subject: Re: [PATCH 04/12] block_dev: only write bdev inode on close
Message-ID: <20150112123351.GA29325@lst.de>
References: <1420739133-27514-1-git-send-email-hch@lst.de> <1420739133-27514-5-git-send-email-hch@lst.de> <20150111173209.GK25319@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150111173209.GK25319@htj.dyndns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 11, 2015 at 12:32:09PM -0500, Tejun Heo wrote:
> Is this an optimization or something necessary for the following
> changes?  If latter, maybe it's a good idea to state why this is
> necessary in the description?  Otherwise,

It gets rid of a bdi reassignment, and thus makes life a lot simpler.
I'll update the commit message.
