Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:34104
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754774Ab1G0VDo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 17:03:44 -0400
Date: Wed, 27 Jul 2011 17:03:44 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        adilger@whamcloud.com, tytso@mit.edu
Subject: Re: [PATCH 3/3] nfsd: vfs_llseek() with O_32BITHASH or O_64BITHASH
Message-ID: <20110727210344.GC9066@infradead.org>
References: <20110727110148.204979.49551.stgit@localhost.localdomain>
 <20110727110259.204979.56782.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110727110259.204979.56782.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 27, 2011 at 01:02:59PM +0200, Bernd Schubert wrote:
> Use 32-bit or 64-bit llseek() hashes for directory offsets depending on
> the NFS version. NFSv2 gets 32-bit hashes only.

Independent of the O_ vs FMODE thing make sure you pass the correct
flag at open time, instead of racy runtime modifications.

