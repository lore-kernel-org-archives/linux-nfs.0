Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59696 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753224AbdGJLrf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Jul 2017 07:47:35 -0400
Date: Mon, 10 Jul 2017 13:47:30 +0200
From: Karel Zak <kzak@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Phil Kauffman <kauffman@cs.uchicago.edu>, linux-nfs@vger.kernel.org
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
Message-ID: <20170710114730.i6dono3adt3xi3tf@ws.net.home>
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu>
 <8737a9x9ky.fsf@notabene.neil.brown.name>
 <595F1A3A.7070405@cs.uchicago.edu>
 <87efto69rs.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87efto69rs.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 10, 2017 at 05:17:27PM +1000, NeilBrown wrote:
> On Fri, Jul 07 2017, Phil Kauffman wrote:
> 
> >> I can imagine /etc/mtab being read once for every line in /etc/exports,
> >> but unless your /etc/exports is very big, I can't easily see why it
> >> would be read 900 times.
> >> Maybe lots of different mount points are being accessed by something and
> >> each one triggers a few reads...
> >>
> >> Can you show your /etc/exports file?
> >
> > These get generated via puppet and dropped into /etc/exports.d/
> ...
> >
> > Here we can see that there are 960 files in /etc/exports.d
> > root@storage1:~# find /etc/exports.d/ -type f | wc
> > 960 960 88701
> 
> Ahhh.. 960 exports.  That could do it.
> 
> $ grep -c crossmnt all_etc_exports.d_in_one_file.txt
> 957
> 
> I get 957 - much the same number.
> 
> $ grep open redacted_strace.txt | uniq -c
>       2 open("/var/lib/nfs/etab", O_RDONLY)     = 6
>     942 open("/etc/mtab", O_RDONLY|O_CLOEXEC)   = 6
>       1 open("/proc/net/rpc/nfsd.export/channel", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 6
> 
> /etc/mtab was ready 942 for a single access.  I would have expected 957,
> but maybe the system is dynamic and something changed between the two
> samples.
> 
> This makes it fairly clear what is happening.  Now we just need to fix
> it.
> One option would be to cache some of the details extracted from
> /etc/mtab, but that could get messy.

Would be possible to read /proc/self/mounts only once and use poll()
to detect changes?

The issue is not only the open()+read() in the process, but also 
kernel has to compose the file from the mount tree. It's expensive.

    Karel


-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
