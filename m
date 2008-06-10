From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [NFS] Does "sync" cause the FUA bit to be set?
Date: Tue, 10 Jun 2008 14:53:31 +0300
Message-ID: <484E6B3B.2030101@panasas.com>
References: <484E5AC1.3020200@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43389 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751937AbYFJLxw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 07:53:52 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K62QA-0007S3-LD
	for linux-nfs@vger.kernel.org; Tue, 10 Jun 2008 21:53:50 +1000
In-Reply-To: <484E5AC1.3020200-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 10, 2008, 13:43 +0300, Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org> wrote:
> Hi,
> 
> we have a raid controller serving a file system that we export and
> mount with NFS. Depending on the performance profile we chose for the 
> raid controller, the are huge performance differences on the NFS client 
> side between two profiles. Those two profiles both use write cache and
> no journaling, but one honors the FUA bit if it is set, and the other 
> profile ignores it (there might be more differences, but the manual
> doesn't state any others but the FUA bit).
> 
> With the profile ignoring the FUA bit, copying or deleting directories
> of e.g. 10M with a about 1000 files is factor 5 faster than with the
> profile honoring the FUA bit.
> 
> We export with the "sync" option. Does that option maybe set the FUA bit
> for all write operations on the NFS server?

No, it's not supposed to that for *all* writes. It's just supposed
to honor the client's synchronous writes and commit calls.
However, the directory is synced after each change (you say above that
files are copied or deleted) with the sync flag and this is more
likely to cause the slowdown you see.

Benny

> 
> cu,
> Frank
> 
> 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

