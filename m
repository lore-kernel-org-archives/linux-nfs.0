Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.offsitebackups.net ([64.251.15.164]:65253 "EHLO
	home.slashze.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752619AbZIBTCG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 15:02:06 -0400
Date: Wed, 2 Sep 2009 15:06:48 -0400
From: Jason Legate <linux-nfs@proxime.net>
To: Peter Chacko <peterchacko35@gmail.com>
Cc: Aaron Wiebe <epiphani@gmail.com>, Jason Legate <linux-nfs@proxime.net>,
        linux-nfs@vger.kernel.org
Subject: Re: NFS for millions of files
Message-ID: <20090902190648.GA15834@proxime.net>
References: <20090902180841.GF946@proxime.net> <e7ca40f70909021119r2f49724dj705e334cf1ae9b3a@mail.gmail.com> <1f808b4a0909021135m49c2e60o6b305babcaed295c@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1f808b4a0909021135m49c2e60o6b305babcaed295c@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFSv3, and I will try various other rsize/wsize.

Apologies for the accidental double post...

We are utilizing XFS with a separate logdev, dedicated raid 1 15k sas drives,
and are already utilizing write caching.  I guess I can try playing with a few
other things.  Thanks for all the pointers.

Jason

It is said that Peter Chacko, at Thu, 03 Sep 2009, wrote:

> Is this NFSv4 ?  rsize and wsize > MTU size will cause fragmentation
> and performance issues...Try making it around 4k .....You used  1<<15
> fir your example. if you don't do writes....then this shouldn't
> matter...and of course NFS is  Nfs is not For Scalability.. You cannot
> get the same performance on NFS as you would get for localFS...May be
> you can try 10g....still there is TCP/UDP/IP stack overhead.....
> 
> 
> On Wed, Sep 2, 2009 at 11:49 PM, Aaron Wiebe<epiphani@gmail.com> wrote:
> > Have a look at these two kernel params - I'd recommend bumping them up
> > to 128 (they're 16 by default).
> >
> > sunrpc.tcp_slot_table_entries
> > sunrpc.udp_slot_table_entries
> >
> > Keep in mind that this could also be a serialization issue. ?If you've
> > got a 3ms latency, and you're performing all of your opens serially,
> > you aren't going to get much faster. ?If you do the work in parallel
> > you'll likely get substantially better numbers.
> >
> > -Aaron
> >
> >
> > On Wed, Sep 2, 2009 at 2:08 PM, Jason Legate<linux-nfs@proxime.net> wrote:
> >> Hi, I'm trying to setup a server that we can create millions of files on over
> >> NFS. ?When I run our creation benchmark locally ?I can get around 3000 files/
> >> second in the configuration we're using now, but only around 300/second over
> >> NFS. ?It's mounted as this:
> >>
> >> rw,nosuid,nodev,noatime,nodiratime,hard,bg,nointr,rsize=32768,wsize=32768,tcp,
> >> nfsvers=3,timeo=600,actimeo=600,nocto
> >>
> >> When I mount the same FS over localhost instead of across the lan, it performs
> >> about full speed (the 3000/sec). ?Anyone have any ideas what I might tweak or
> >> look at?
> >>
> >> We're going to be testing various XFS/LVM configs to get the best performance,
> >> but right out the gate, NFS having a 10:1 penalty of performance doesn't bode
> >> well.
> >>
> >> Thanks in advance,
> >> Jason
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at ?http://vger.kernel.org/majordomo-info.html
> >>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at ?http://vger.kernel.org/majordomo-info.html
> >
> 
> 
> 
> -- 
> Best regards,
> Peter Chacko
> 
> NetDiox computing systems,
> Network storage & OS  training and research.
> Bangalore, India.
> www.netdiox.com
> 080 2664 0708
