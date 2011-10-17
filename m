Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41751 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751914Ab1JQNjC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 09:39:02 -0400
Date: Mon, 17 Oct 2011 09:39:01 -0400
To: Harald Dunkel <harald.dunkel@aixigo.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs3 30% faster than nfs4?
Message-ID: <20111017133901.GB9809@fieldses.org>
References: <4E9BDF01.6090106@aixigo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E9BDF01.6090106@aixigo.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 17, 2011 at 09:53:37AM +0200, Harald Dunkel wrote:
> Hi folks,
> 
> I did a brief test on a local nfs server: Extracting the
> linux kernel sources on a nfs partition it seems that nfs3
> is 30% faster than nfs4. For nfs3 I got 5.2MB/sec. Nfs4
> gave me just 3.8MB/sec. The server was idle except for this
> test.
> 
> Client and server were running 2.6.39 from the Debian backports
> repository. I just changed the mount option on the client to
> select nfs3 or nfs4.
> 
> I don't want to complain, but I did not expect this huge loss
> in performance for moving to nfs4. Any helpful comment would be
> highly appreciated.

It might be worth looking at /proc/self/mountstats and seeing if you can
figure out where the time's going in the v4 case.  (Probably
open/close?)

That workload is unlikely to be bandwidth-limited so total time is
probably the better number to look at instead of bandwidth.

--b.
