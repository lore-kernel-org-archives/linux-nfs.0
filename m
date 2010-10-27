Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:61994 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754206Ab0J0SUp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 14:20:45 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd changes for 2.6.37
Date: Wed, 27 Oct 2010 20:20:32 +0200
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <20101026164549.GD19445@fieldses.org> <AANLkTinTXoGiFap-vfu0P_SXb5xS+gMsHOwQtN3Hra3r@mail.gmail.com> <20101027174016.GA18974@fieldses.org>
In-Reply-To: <20101027174016.GA18974@fieldses.org>
Content-Type: Text/Plain;
  charset="utf-8"
Message-Id: <201010272020.33049.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wednesday 27 October 2010 19:40:16 J. Bruce Fields wrote:
> Doesn't matter to me.  What I've currently got (Arnd's patches with some
> minor fixes from me, and your patch, all in a poorly changelogged
> jumble) is in
> 
>         git://linux-nfs.org/~bfields/linux-topics.git TMP-BKL-TESTING
> 
> You wouldn't want to merge that as is, but it does seem to work.

Ok, then let's use your tree with proper changelogs. That should be the
easiest way to make sure that the code you test is the one that gets in.

	Arnd
