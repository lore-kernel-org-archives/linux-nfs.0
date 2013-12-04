Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51288 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753590Ab3LDSZC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Dec 2013 13:25:02 -0500
Date: Wed, 4 Dec 2013 13:24:59 -0500
To: Christoph Hellwig <hch@infradead.org>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
Message-ID: <20131204182459.GA17791@fieldses.org>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain>
 <20131124051904.GA16651@master.debian.org>
 <20131124090924.GA29659@infradead.org>
 <20131124130753.GA15178@umich.edu>
 <20131204131317.GA7776@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131204131317.GA7776@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 04, 2013 at 05:13:17AM -0800, Christoph Hellwig wrote:
> Btw, looks like librpcsecgss is indeed pretty much unmaintained.  The
> last upstream release is a tarball drop from CITI in 2009 and there
> doesn't appear to be a source repository of any kind.

Well, there is this:

	git://git.linux-nfs.org/projects/kwc/librpcsecgss.git

which was probably the source of the tarball?

--b.

> 
> I think the best idea would be to merge it into the libtirpc repo,
> as both the heritage and usage of the codebases is the same.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
