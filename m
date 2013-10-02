Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44211 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093Ab3JBQG6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 12:06:58 -0400
Date: Wed, 2 Oct 2013 09:06:54 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, Boaz Harrosh <bharrosh@panasas.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
Message-ID: <20131002160654.GA27988@infradead.org>
References: <1380220810-12909-1-git-send-email-bhalevy@primarydata.com>
 <20130929114327.GB25750@infradead.org>
 <52481939.7060405@primarydata.com>
 <20130929121345.GA21083@infradead.org>
 <52481B11.2080407@primarydata.com>
 <20130929122130.GI21083@infradead.org>
 <20130929123553.GA7510@infradead.org>
 <524A1FCE.5030306@panasas.com>
 <20131001133335.GB32431@infradead.org>
 <524C050E.4010102@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <524C050E.4010102@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 02, 2013 at 02:35:42PM +0300, Benny Halevy wrote:
> For loosely clustered files-layout file systems the MDS would also
> need to handle LAYOUTCOMMIT, and also generate and handle layout recalls,
> depending on how much of that we can do in a generic way and how much is
> file system specific.

Which is something we can deal with in great detail once such a
filesystem and the pnfs support for it land in the kernel tree.

