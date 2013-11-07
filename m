Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53756 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab3KGRr2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 12:47:28 -0500
Date: Thu, 7 Nov 2013 09:47:24 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Benny Halevy <bhalevy@primarydata.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: remove_stid can be incorporated into
 nfs4_put_delegation
Message-ID: <20131107174724.GA17242@infradead.org>
References: <525CE711.1040107@primarydata.com>
 <1381820280-14120-1-git-send-email-bhalevy@primarydata.com>
 <20131104224758.GB8828@fieldses.org>
 <52786E74.8030505@primarydata.com>
 <20131107170204.GA10530@infradead.org>
 <20131107170553.GD21932@fieldses.org>
 <20131107171908.GA23455@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131107171908.GA23455@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 07, 2013 at 09:19:08AM -0800, Christoph Hellwig wrote:
> On Thu, Nov 07, 2013 at 12:05:53PM -0500, J. Bruce Fields wrote:
> > What did you run it on exactly?  (One of my branches or one of Benny's?)
> 
> Bennys tree (+ some local changes)
> 
> > I keep saying I should do regular xfstest runs and keep not doing it.
> > Do you have a sample commandline to share for nfs testing?
> 
> cat > /etc/xfsqa.config << EOF
> TEST_DIR=/mnt/nfs1
> TEST_DEV=127.0.0.1:/mnt/test
> EOF

Sorry, this missed half of what's needed:

SCRATCH_MNT=/mnt/nfs1
SCRATCH_DEV=127.0.0.1:/mnt/scratch

For historical reason xfstests mixes up the scratch and test devices
for NFS in many older tests.

