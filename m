Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:58136 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837Ab2DFJnC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Apr 2012 05:43:02 -0400
Received: by wejx9 with SMTP id x9so1361811wej.19
        for <linux-nfs@vger.kernel.org>; Fri, 06 Apr 2012 02:43:00 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>
Cc: "bfields\@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [REGRESSION] NFSv4: open(O_TRUNC) hangs
References: <87d37osrx2.fsf@tucsk.pomaz.szeredi.hu>
	<1333647115.4573.3.camel@lade.trondhjem.org>
Date: Fri, 06 Apr 2012 11:43:29 +0200
In-Reply-To: <1333647115.4573.3.camel@lade.trondhjem.org> (Trond Myklebust's
	message of "Thu, 5 Apr 2012 17:31:58 +0000")
Message-ID: <8762ddb3ge.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Myklebust, Trond" <Trond.Myklebust@netapp.com> writes:

> The following client patch fixes the regression for me.

It fixes the hang, but it still doesn't work 100% correctly.  Try the
following test program.

BTW, do you run any fs test suits?  All these were caught with one I use
to quick test fuse (it's in the fuse git tree(*) under the "test"
directory).  But I guess others like LTP would catch these as well.

Thanks,
Miklos

(*)  git://fuse.git.sourceforge.net/gitroot/fuse/fuse
---

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

int main(int argc, char *argv[])
{
	int res;
	char *name = argv[1];

	unlink(name);
	close(creat(name, 0400));
	res = open(name, O_RDONLY | O_TRUNC);
	if (res != -1 && errno != EPERM)
		fprintf(stderr, "should have failed!\n");

	return 0;
}
