Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40544 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757902AbcCUUkm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 16:40:42 -0400
Date: Mon, 21 Mar 2016 16:40:41 -0400
To: Richard Yao <ryao@gentoo.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: Making an interface for alternative data streams
Message-ID: <20160321204041.GA807@fieldses.org>
References: <56F03945.40208@gentoo.org>
 <56F05745.50204@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56F05745.50204@gentoo.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 21, 2016 at 04:19:17PM -0400, Richard Yao wrote:
> Maybe I should clarify that the idea is to allow read/write/list of
> extended attributes via read/write/readdir so that those that want
> extended attributes that are alternative data streams can have them. I
> do not want to see extended attributes and alternative data streams be
> different things.

I think there are differences between the two that make this awkward.
Does anyone actually use alternative data stream for anything that makes
the effort worthwhile?

> Alternative data streams are in the NFSv4 specification, so I thought
> that the developers of the NFS client driver would want something like
> this.

Somebody would have to make a convincing argument that it's worthwhile.

Note there's also a proposal to add extended attributes to the NFSv4
protocol:

	https://tools.ietf.org/html/draft-ietf-nfsv4-xattrs-02

That also has some more discussion of mismatches between the named- and
extended- attribute interfaces:

	https://tools.ietf.org/html/draft-ietf-nfsv4-xattrs-02#section-5

--b.
