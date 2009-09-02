Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:59946 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbZIBSTP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 14:19:15 -0400
Received: by bwz19 with SMTP id 19so925166bwz.37
        for <linux-nfs@vger.kernel.org>; Wed, 02 Sep 2009 11:19:16 -0700 (PDT)
In-Reply-To: <20090902180841.GF946@proxime.net>
References: <20090902180841.GF946@proxime.net>
Date: Wed, 2 Sep 2009 14:19:16 -0400
Message-ID: <e7ca40f70909021119r2f49724dj705e334cf1ae9b3a@mail.gmail.com>
Subject: Re: NFS for millions of files
From: Aaron Wiebe <epiphani@gmail.com>
To: Jason Legate <linux-nfs@proxime.net>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Have a look at these two kernel params - I'd recommend bumping them up
to 128 (they're 16 by default).

sunrpc.tcp_slot_table_entries
sunrpc.udp_slot_table_entries

Keep in mind that this could also be a serialization issue.  If you've
got a 3ms latency, and you're performing all of your opens serially,
you aren't going to get much faster.  If you do the work in parallel
you'll likely get substantially better numbers.

-Aaron


On Wed, Sep 2, 2009 at 2:08 PM, Jason Legate<linux-nfs@proxime.net> wrote:
> Hi, I'm trying to setup a server that we can create millions of files on over
> NFS.  When I run our creation benchmark locally  I can get around 3000 files/
> second in the configuration we're using now, but only around 300/second over
> NFS.  It's mounted as this:
>
> rw,nosuid,nodev,noatime,nodiratime,hard,bg,nointr,rsize=32768,wsize=32768,tcp,
> nfsvers=3,timeo=600,actimeo=600,nocto
>
> When I mount the same FS over localhost instead of across the lan, it performs
> about full speed (the 3000/sec).  Anyone have any ideas what I might tweak or
> look at?
>
> We're going to be testing various XFS/LVM configs to get the best performance,
> but right out the gate, NFS having a 10:1 penalty of performance doesn't bode
> well.
>
> Thanks in advance,
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
