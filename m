Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51764 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218AbcGAQJB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 12:09:01 -0400
Date: Fri, 1 Jul 2016 12:08:57 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Marc Eshel <eshel@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: grace period
Message-ID: <20160701160857.GB20327@fieldses.org>
References: <1465939516-44769-1-git-send-email-trond.myklebust@primarydata.com>
 <OF44E4DD0C.FF5B6C3E-ON88257FE2.00771383-88257FE2.007798E3@notes.na.collabserv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF44E4DD0C.FF5B6C3E-ON88257FE2.00771383-88257FE2.007798E3@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 30, 2016 at 02:46:19PM -0700, Marc Eshel wrote:
> I see that setting the number of nfsd threads to 0 (echo 0 > 
> /proc/fs/nfsd/threads) is not releasing the locks and putting the server 
> in grace mode.

Writing 0 to /proc/fs/nfsd/threads shuts down knfsd.  So it should
certainly drop locks.  If that's not happening, there's a bug, but we'd
need to know more details (version numbers, etc.) to help.

That alone has never been enough to start a grace period--you'd have to
start knfsd again to do that.

> What is the best way to go into grace period, in new version of the
> kernel, without restarting the nfs server?

Restarting the nfs server is the only way.  That's true on older kernels
true, as far as I know.  (OK, you can apparently make lockd do something
like this with a signal, I don't know if that's used much, and I doubt
it works outside an NFSv3-only environment.)

So if you want locks dropped and a new grace period, then you should run
"systemctl restart nfs-server", or your distro's equivalent.

But you're probably doing something more complicated than that.  I'm not
sure I understand the question....

--b.
