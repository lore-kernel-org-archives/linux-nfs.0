Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:38600 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751816AbdCCPRb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Mar 2017 10:17:31 -0500
Date: Fri, 3 Mar 2017 07:16:45 -0800
From: Christoph Hellwig <hch@infradead.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Confused by pnfs LAYOUTRETURN - seeking clarity.
Message-ID: <20170303151645.GB7751@infradead.org>
References: <87shmvnzh7.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87shmvnzh7.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

sorry for the sparse reply, I'm travelling right now,

take a look at the NFS4ERR_NOMATCHING_LAYOUT error in NFSv4.2
and maybe try to do an internet search for forgetful clients - that's
the way how the Linux pNFS client operates using the above error
to signal it doesn't have any outstanding layouts when responding
to a layoutrecall.
