From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [NFS] Does "sync" cause the FUA bit to be set?
Date: Tue, 10 Jun 2008 11:44:06 -0400
Message-ID: <484EA146.8070201@gmail.com>
References: <484E5AC1.3020200@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:48409 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753201AbYFJPlg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 11:41:36 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K65yY-00047G-4p
	for linux-nfs@vger.kernel.org; Wed, 11 Jun 2008 01:41:34 +1000
In-Reply-To: <484E5AC1.3020200-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Frank Steiner wrote:
> With the profile ignoring the FUA bit, copying or deleting directories
> of e.g. 10M with a about 1000 files is factor 5 faster than with the
> profile honoring the FUA bit.
>   
FUA bit is normally combined with write-thru scsi command that bypasses 
storage write cache. I would imagine it needs to well synchronize 
various pieces before issuing this command. It could hurt the 
performance if not done well, particularly for meta data. So your result 
is not surprising.
> We export with the "sync" option. Does that option maybe set the FUA bit
> for all write operations on the NFS server?
>   
It depends on how the filesystem (and its associated disk subsystem) is 
implemented. The "sync" export option itself has a heavy performance 
impact, regardless how FUA bit is handled. Some vendors uses specialized 
HW (e.g. NVRAM) to alleviate this performance hit. If your filesystem 
doesn't have this type of support, you should expect "sync" option runs 
much much slower than "async". It is a choice (or balance) between cost, 
performance, and data reliability.

Don't you have the vendor's support group to go ? Better get this answer 
from the storage vendor directly.

-- Wendy


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

