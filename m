Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48993 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757536Ab3KMQP3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 11:15:29 -0500
Date: Wed, 13 Nov 2013 08:15:27 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
Message-ID: <20131113161527.GA10046@infradead.org>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
 <20131112194529.GA26341@fieldses.org>
 <52828767.3030909@netapp.com>
 <20131112195911.GA28033@fieldses.org>
 <5283A24D.4010309@netapp.com>
 <5283A3B7.8080405@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5283A3B7.8080405@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 13, 2013 at 11:07:19AM -0500, Anna Schumaker wrote:
> I'm thinking something like this:

Given that the whole sparse file support seems more experimental than
the security labels requiring the former for the latter seems a bit odd.

I have to admit that I don't really know how to deal with those changes,
on the one hand I'd love to expose it as soon as possible, on the other
hand the spec has so many higher level flaws related to their concepts
of sparse files that I'd feel really bad about locking even parts of it
in at the moment.

