From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux 2.6.27.13
Date: Wed, 28 Jan 2009 14:33:47 -0500
Message-ID: <1233171227.9785.28.camel@heimdal.trondhjem.org>
References: <20090125004823.GA6711@kroah.com>  <4980565E.3000800@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
	stable@kernel.org, linux-nfs@vger.kernel.org,
	autofs-CPWUtch7KCBzeIdxy0IIJw@public.gmane.org
To: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:39358 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750943AbZA1Tdx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2009 14:33:53 -0500
In-Reply-To: <4980565E.3000800-Q2TZfHgGEy4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-01-28 at 13:58 +0100, Jesper Krogh wrote:
> Greg KH wrote:
> > We (the -stable team) are announcing the release of the 2.6.27.13
> > kernel.
> > 
> > It contains a wide range of bugfixes, and all users of the 2.6.27 kernel
> > series are strongly encouraged to upgrade.
> > 
> > I'll also be replying to this message with a copy of the patch between
> > 2.6.27.12 and 2.6.27.13
> 
> Still on a 2.6.27.6  I got this on an NFS client while restarting the 
> NFS-server at the other end. Seems autofs/nfs releated.
> 
> 
> [6367172.212954] ------------[ cut here ]------------
> [6367172.213122] kernel BUG at net/sunrpc/rpcb_clnt.c:498!

Already fixed in 2.6.28 by the following commit.
  http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=9a4bd29fe8f6d3f015fe1c8e5450eb62cfebfcc9

You should probably also apply the following commit (also in 2.6.28),
which fixes a memory leak in the same area.
  http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=96165e2b7c4e2c82a0b60c766d4a2036444c21a0

Cheers
  Trond

