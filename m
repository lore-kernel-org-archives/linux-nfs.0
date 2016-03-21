Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:44392 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745AbcCUWgp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 18:36:45 -0400
Date: Mon, 21 Mar 2016 18:36:27 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Richard Yao <ryao@gentoo.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: Making an interface for alternative data streams
Message-ID: <20160321223627.GA12999@thunk.org>
References: <56F03945.40208@gentoo.org>
 <56F05745.50204@gentoo.org>
 <20160321204041.GA807@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160321204041.GA807@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 21, 2016 at 04:40:41PM -0400, J. Bruce Fields wrote:
> On Mon, Mar 21, 2016 at 04:19:17PM -0400, Richard Yao wrote:
> > Maybe I should clarify that the idea is to allow read/write/list of
> > extended attributes via read/write/readdir so that those that want
> > extended attributes that are alternative data streams can have them. I
> > do not want to see extended attributes and alternative data streams be
> > different things.
> 
> I think there are differences between the two that make this awkward.
> Does anyone actually use alternative data stream for anything that makes
> the effort worthwhile?

Windows malware authors *love* to use alternate data streams as a
place to hide their malware where many security scanners weren't
looking, and certainly most users won't find.

Does that count?   :-)

						- Ted
