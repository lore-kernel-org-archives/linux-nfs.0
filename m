Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:54688
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755507Ab1G1LrC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 07:47:02 -0400
Date: Thu, 28 Jul 2011 07:46:59 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        yong.fan@whamcloud.com, adilger@whamcloud.com, tytso@mit.edu
Subject: Re: [PATCH 3/3] nfsd: vfs_llseek() with O_32BITHASH or O_64BITHASH
Message-ID: <20110728114659.GA13296@infradead.org>
References: <20110727110148.204979.49551.stgit@localhost.localdomain>
 <20110727110259.204979.56782.stgit@localhost.localdomain>
 <20110727210344.GC9066@infradead.org>
 <4E31298B.7050800@itwm.fraunhofer.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E31298B.7050800@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 28, 2011 at 11:19:07AM +0200, Bernd Schubert wrote:
> before I'm going to work further on the patch sets, I have few
> questions first. Could you please help me with that?
> 
> file->f_mode is set in __dentry_open() based on O_ flags.

Or right after dentry_open, before anyone can possibly grab a reference
to the file.  Just do that in nfsd_open based on an NFSD_MAY_ flag.

