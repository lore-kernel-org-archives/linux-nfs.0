From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] Does "sync" cause the FUA bit to be set?
Date: Tue, 10 Jun 2008 15:47:12 -0400
Message-ID: <20080610194712.GP20184@fieldses.org>
References: <484E5AC1.3020200@bio.ifi.lmu.de> <484EA146.8070201@gmail.com>
	<484EA215.5090000@panasas.com> <484ECD58.8040100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Benny Halevy <bhalevy@panasas.com>,
	Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>,
	nfs@lists.sourceforge.net
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43359 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754437AbYFJTrc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 15:47:32 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K69oY-0004uU-B0
	for linux-nfs@vger.kernel.org; Wed, 11 Jun 2008 05:47:30 +1000
In-Reply-To: <484ECD58.8040100@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 10, 2008 at 01:52:08PM -0500, Wendy Cheng wrote:
> Benny Halevy wrote:
> > On Jun. 10, 2008, 18:44 +0300, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
> >   
> >> Frank Steiner wrote:
> >>     
> >>> With the profile ignoring the FUA bit, copying or deleting directories
> >>> of e.g. 10M with a about 1000 files is factor 5 faster than with the
> >>> profile honoring the FUA bit.
> >>>   
> >>>       
> >> FUA bit is normally combined with write-thru scsi command that bypasses 
> >> storage write cache. I would imagine it needs to well synchronize 
> >> various pieces before issuing this command. It could hurt the 
> >> performance if not done well, particularly for meta data. So your result 
> >> is not surprising.
> >>     
> >>> We export with the "sync" option. Does that option maybe set the FUA bit
> >>> for all write operations on the NFS server?
> >>>   
> >>>       
> >> It depends on how the filesystem (and its associated disk subsystem) is 
> >> implemented. The "sync" export option itself has a heavy performance 
> >> impact, regardless how FUA bit is handled. Some vendors uses specialized 
> >> HW (e.g. NVRAM) to alleviate this performance hit. If your filesystem 
> >> doesn't have this type of support, you should expect "sync" option runs 
> >> much much slower than "async". It is a choice (or balance) between cost, 
> >> performance, and data reliability.
> >>     
> >
> > Wendy, I *think* what you have in mind is the sync mount option
> > rather than the sync export flag.  The latter just tells the server
> > not to cheat and do everything asynchronously.  It should *not*
> > have a heavy performance penalty for I/O intensive writes if the
> > client is using async writes and commits.
> >
> >   
> No, I didn't get confused ... We can use Linux as an example :) .. check 
> out:
> http://marc.info/?l=linux-nfs&m=119618886105337&w=2
> 
> -- quote
> 
> The default export might have been "async", but unless the option "sync"
> in /etc/exports was being ignored I was already using "sync". Nevertheless
> I will try to change to async and test if it makes a difference.
> 
> (one day later: )
> 
> I have now tried it and the load on the NFS server is much lower and KDE
> logins seem to be reasonably fast now.

Yeah, the "async" export options is expected to improve performance on a
workload like that (with lots of directory creates/deletes).  But it
does so by violating the promises that the protocol makes to the client.

--b.

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

