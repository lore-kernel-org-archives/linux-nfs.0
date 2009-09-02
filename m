Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.offsitebackups.net ([64.251.15.164]:64877 "EHLO
	home.slashze.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753311AbZIBSzq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 14:55:46 -0400
Date: Wed, 2 Sep 2009 15:00:31 -0400
From: Jason Legate <jlegate@proxime.net>
To: Aaron Wiebe <epiphani@gmail.com>
Cc: Jason Legate <linux-nfs@proxime.net>, linux-nfs@vger.kernel.org
Subject: Re: NFS for millions of files
Message-ID: <20090902190031.GG946@proxime.net>
References: <20090902180841.GF946@proxime.net> <e7ca40f70909021119r2f49724dj705e334cf1ae9b3a@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <e7ca40f70909021119r2f49724dj705e334cf1ae9b3a@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

It is said that Aaron Wiebe, at Wed, 02 Sep 2009, wrote:

> Have a look at these two kernel params - I'd recommend bumping them up
> to 128 (they're 16 by default).
> 
> sunrpc.tcp_slot_table_entries
> sunrpc.udp_slot_table_entries

They were indeed 16.  I've bumped them up to 128, and am trying again.

> Keep in mind that this could also be a serialization issue.  If you've
> got a 3ms latency, and you're performing all of your opens serially,
> you aren't going to get much faster.  If you do the work in parallel
> you'll likely get substantially better numbers.

It appears it might just be serialization.  When I run more than 1 thread,
I can consistently get between 200 and 250 files/thread/second (up to about
10 threads, at which point I get diminishing returns per thread).

I seem to be doing a lot of GETATTR's, and it appears to be driven by perl.
We are open()'ing files with +>filename and apparently perl will do an fstat
for us after opening.  Thanks for the tip, Aaron!

-j

> -Aaron
> 
> 
> On Wed, Sep 2, 2009 at 2:08 PM, Jason Legate<linux-nfs@proxime.net> wrote:
> > Hi, I'm trying to setup a server that we can create millions of files on over
> > NFS. ?When I run our creation benchmark locally ?I can get around 3000 files/
> > second in the configuration we're using now, but only around 300/second over
> > NFS. ?It's mounted as this:
> >
> > rw,nosuid,nodev,noatime,nodiratime,hard,bg,nointr,rsize=32768,wsize=32768,tcp,
> > nfsvers=3,timeo=600,actimeo=600,nocto
> >
> > When I mount the same FS over localhost instead of across the lan, it performs
> > about full speed (the 3000/sec). ?Anyone have any ideas what I might tweak or
> > look at?
> >
> > We're going to be testing various XFS/LVM configs to get the best performance,
> > but right out the gate, NFS having a 10:1 penalty of performance doesn't bode
> > well.
> >
> > Thanks in advance,
> > Jason
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at ?http://vger.kernel.org/majordomo-info.html
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
