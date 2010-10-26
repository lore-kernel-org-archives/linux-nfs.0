From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd changes for 2.6.37
Date: Tue, 26 Oct 2010 13:46:48 -0400
Message-ID: <20101026174648.GA1842@fieldses.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101026172250.GB526@fieldses.org>
 <AANLkTi=emsmLNFSV=j48d37JQxecQmNGZwY9OYdoKjeS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49440 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760165Ab0JZRqt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 13:46:49 -0400
In-Reply-To: <AANLkTi=emsmLNFSV=j48d37JQxecQmNGZwY9OYdoKjeS-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 26, 2010 at 10:39:41AM -0700, Linus Torvalds wrote:
> But even that kind of "both non-merged and pre-merged" pull requests
> should be reserved just for cases where there really was a somewhat
> involved conflict. For trivial conflicts like a feature removal doc
> clash, don't even bother.  I do several trivial merges a day, it's
> normal and it doesn't really take me any appreciable extra time. Git
> command line of the day:
> 
>   git log --oneline v2.6.36.. --merges --author=Torvalds --grep=onflict
> 
> to see at least a partial list of the trivial conflicts I've done in
> just this merge window. It's 3-4 per day, it's perfectly normal.

Makes sense, thanks!

--b.
