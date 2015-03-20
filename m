Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46016 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbbCTQYb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Mar 2015 12:24:31 -0400
Date: Fri, 20 Mar 2015 09:24:30 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [GIT] nfsd bugfix for 4.0
Message-ID: <20150320162430.GB18786@infradead.org>
References: <20150320162147.GF2036@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150320162147.GF2036@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI, I think the patch Kinglong Mee sent today is the better fix,
together with the mangled patch description in mine it might be better
to send that after a little bit of testing.
