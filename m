Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39877 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154AbaA3SeZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jan 2014 13:34:25 -0500
Date: Thu, 30 Jan 2014 13:34:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: please pull nfsd changes for 3.14
Message-ID: <20140130183424.GE30065@fieldses.org>
References: <20140129185449.GC30065@fieldses.org>
 <CA+55aFxCb7ai5T3HGyr1AZTyEvKi1VjtMkF0aZWEXRSW2ZC7zQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFxCb7ai5T3HGyr1AZTyEvKi1VjtMkF0aZWEXRSW2ZC7zQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 30, 2014 at 10:23:06AM -0800, Linus Torvalds wrote:
> On Wed, Jan 29, 2014 at 10:54 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > Stephen Rothwell noted a merge conflict:
> >
> > http://marc.info/?i=<20140129124238.6e1667abab08be8be2dafe01@canb.auug.org.au>
> >
> > I'm assuming as usual you'll handle it and let me know if you need
> > anything from me.
> 
> Heh. The conflict was trivial, and git does 99% of it automatically -
> leaving just the header file inclusions to be resolved manually
> because they were right next to each other. The resolution just looks
> scarier than it is because there were other changes that did resolve
> cleanly, but that were "close enough" to each other that the context
> overlapped, so they are shown too..
> 
> But yes, had it actually been complicated, I'd probably still have
> done it, and perhaps asked you to verify it. We did have a couple of
> more serious conflicts in this merge window.

Good, thanks!

--b.
