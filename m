Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:53505 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328Ab0J0UUY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 16:20:24 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd changes for 2.6.37
Date: Wed, 27 Oct 2010 22:20:20 +0200
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <20101026164549.GD19445@fieldses.org> <201010272148.47376.arnd@arndb.de> <20101027200145.GE18974@fieldses.org>
In-Reply-To: <20101027200145.GE18974@fieldses.org>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201010272220.20567.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wednesday 27 October 2010 22:01:45 J. Bruce Fields wrote:
> (You're missing Linus's comment fix, though, unless I'm confused.)

Right, I didn't look into the attachment, so I hadn't noticed
the new changelog. I've updated the changelog to Linus' version,
as it's more verbose than mine.

I also checked that the version in your tree is actually the
right one, so I left the code untouched.

	Arnd
