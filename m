Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50512 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbbBEOFa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 09:05:30 -0500
Date: Thu, 5 Feb 2015 06:05:26 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: Boaz Harrosh <boaz@plexistor.com>, dE <de.techno@gmail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Cant get to export this particular directory.
Message-ID: <20150205140526.GA28544@infradead.org>
References: <54D237A5.1050302@gmail.com>
 <20150204170356.14e1e381@harpe.intellique.com>
 <54D24403.2080403@gmail.com>
 <54D34CB8.1040008@plexistor.com>
 <1934902055.820990.1423137608454.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1934902055.820990.1423137608454.JavaMail.zimbra@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 05, 2015 at 01:00:08PM +0100, Mkrtchyan, Tigran wrote:
> > Reason I'm asking is because it looks a little bit like when the FS does not
> > support the export_operations vector. The Kernel nfsd is not very good
> 
> Then this does not explain why mounting on a local host works.

Hard to guestimate over weird out of tree code.  If this is reproducible
with an in tree filesystem someone might have a chance to understand it.
