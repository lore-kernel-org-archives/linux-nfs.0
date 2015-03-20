Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41027 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993AbbCTQlb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2015 12:41:31 -0400
Date: Fri, 20 Mar 2015 12:41:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [GIT] nfsd bugfix for 4.0
Message-ID: <20150320164130.GG2036@fieldses.org>
References: <20150320162147.GF2036@fieldses.org>
 <20150320162430.GB18786@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150320162430.GB18786@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 20, 2015 at 09:24:30AM -0700, Christoph Hellwig wrote:
> FYI, I think the patch Kinglong Mee sent today is the better fix,
> together with the mangled patch description in mine it might be better
> to send that after a little bit of testing.

Gah, I'm not keeping up with my mail.

I've got Kinglong Mee's patch queued up as incremental patch on top of
this pull request.  I think it's not that critical.

(But Linus if you want to drop this I can submit the revised patch with
other stuff next week, I don't care much either way.)

--b.
