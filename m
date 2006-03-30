From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS/Kernel Problem: getfh failed: Operation not permitted
Date: Thu, 30 Mar 2006 10:09:24 -0500
Message-ID: <1143731364.8074.53.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0603300813270.18696@p34>
	 <1143728720.8074.41.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0603300929340.18696@p34>
	 <1143729766.8074.49.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0603300949000.18696@p34>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750784AbWC3PJl@vger.kernel.org>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
In-Reply-To: <Pine.LNX.4.64.0603300949000.18696@p34>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 2006-03-30 at 09:50 -0500, Justin Piszcz wrote:
> I tried an exportfs -rv and it did not help.  Any other suggestions?

Did the output from 'exportfs -rv' match with the contents
of /etc/exports? If so, did it also match with the contents
of /var/lib/nfs/xtab and /proc/fs/nfs/exports?

Cheers,
  Trond
