Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48399 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320Ab1KMQmv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Nov 2011 11:42:51 -0500
Date: Sun, 13 Nov 2011 11:42:40 -0500
To: NeilBrown <neilb@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Matthew Treinish <treinish@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20111113164240.GB28574@fieldses.org>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321056809.8733.2.camel@lade.trondhjem.org>
 <20111112144953.GA3740@infradead.org>
 <20111113145400.6c7a9be3@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111113145400.6c7a9be3@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 13, 2011 at 02:54:00PM +1100, NeilBrown wrote:
> So if you know the filesystem will only return FHEXPIRED for filehandles
> belonging to files that cannot be renamed, then it is perfectly reasonable to
> repeat the name lookup to re-access the file after the server forgets about
> an old filehandle.  The mount option is how you communicate this knowledge,
> because the RFC doesn't provide a way to communicate it.

What about http://tools.ietf.org/html/rfc5661#section-11.11
STATUS4_FIXED?

--b.
