Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40565 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964815AbbDXQcN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Apr 2015 12:32:13 -0400
Date: Fri, 24 Apr 2015 12:32:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [GIT] nfsd changes for 4.0
Message-ID: <20150424163212.GA9097@fieldses.org>
References: <20150423151205.GB22158@fieldses.org>
 <CA+55aFy3DxbUn8LRqre2BGTR-tXe=ijOwhHpoZ9Yzdf=KrNnkg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFy3DxbUn8LRqre2BGTR-tXe=ijOwhHpoZ9Yzdf=KrNnkg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2015 at 07:47:59AM -0700, Linus Torvalds wrote:
> On Thu, Apr 23, 2015 at 8:12 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Please pull nfsd changes for 4.0 from:
> >
> >   git://linux-nfs.org/~bfields/linux.git for-4.0
> 
> You meant "for-4.1".

Yes.

> Please script this better so that the pull target itself is also part
> of the script - clearly you used the right name at some point since
> the shortlog and diffstat is about the right for-4.1 branch...

My (trivial) script was doing "git request-pull origin <url>" which
leaves request-pull to pick a matching ref name at random, which I was
then fixing up by hand.  If I pass the right branch name as the third
argument, the problem's fixed--done, thanks.

--b.
