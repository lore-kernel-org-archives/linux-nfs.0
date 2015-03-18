Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:49409 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755514AbbCRKue (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Mar 2015 06:50:34 -0400
Date: Wed, 18 Mar 2015 11:50:30 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150318105030.GA21390@lst.de>
References: <20150303221033.GB19439@fieldses.org> <20150315125821.GA10655@lst.de> <20150316142721.GA12231@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150316142721.GA12231@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 16, 2015 at 10:27:21AM -0400, J. Bruce Fields wrote:
> 	NFS_MOUNT_OPTIONS="-overs=4.1"
> 	EOF
> 	./check -nfs -g auto -E ~/xfstests-skip
> 
> where xfs-tests-skip is:

Seems like you're excluding a lot of tests.

Either way, both generic/011 and generic/013 cause the bug I reported earlier,
so at least on 4.0-rc I don't really get close to running into these
pnfs issues.

Do you have a commit you're runing on that's before the nfs client merge
and somewhat stable?
