Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:55710 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752521AbdBCNcF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 3 Feb 2017 08:32:05 -0500
MIME-Version: 1.0
Message-ID: <trinity-7dd256c6-d4b4-4f47-9911-168ed4cf5075-1486128686520@3capp-mailcom-bs01>
From: daggs <daggs@gmx.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: unable to mount nfs4 mount
Content-Type: text/plain; charset=UTF-8
Date: Fri, 3 Feb 2017 14:31:26 +0100
In-Reply-To: <871swflfxo.fsf@notabene.neil.brown.name>
References: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14>
 <87r34yngxn.fsf@notabene.neil.brown.name>
 <trinity-f47ff353-231a-48ff-b6d4-a8f34c45ea26-1482563498427@3capp-mailcom-bs14>
 <87lgv5nmi6.fsf@notabene.neil.brown.name>
 <trinity-8111cff0-0509-405f-8faa-190a3c9291c6-1482609137078@3capp-mailcom-bs11>
 <87inq8olcj.fsf@notabene.neil.brown.name>
 <trinity-c0b9c914-6d36-40d8-a13a-38cde8b7d23f-1482696592233@3capp-mailcom-bs03>
 <87fulboij2.fsf@notabene.neil.brown.name>
 <trinity-161ef8fa-88f7-4128-85e2-cc4f1abb31a7-1482738488938@3capp-mailcom-bs14>
 <87d1gfndin.fsf@notabene.neil.brown.name>
 <trinity-02157c25-8763-4394-ad29-2b05c954f503-1482778484415@3capp-mailcom-bs02>
 <87h95fms28.fsf@notabene.neil.brown.name>
 <trinity-72ebcb17-21db-44da-abb3-5ee70ac0ec32-1483706005238@3capp-mailcom-bs05>,
 <871swflfxo.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings,

> On Fri, Jan 06 2017, daggs wrote:
> 
> > Greetings,
> >
> >> Subject: Re: unable to mount nfs4 mount
> >>
> >> On Tue, Dec 27 2016, daggs wrote:
> >> 
> >> > Greetings Neil,
> >> >
> >> >> On Mon, Dec 26 2016, daggs wrote:
> >> >> 
> >> >> > Greetings,
> >> >> >
> >> >> >> On Mon, Dec 26 2016, daggs wrote:
> >> >> >> 
> >> >> >> >> Can you strace mountd while you attempt a mount?
> >> >> >> >> e.g.
> >> >> >> >>   strace -o /tmp/trace -s 1000 -p 241
> >> >> >> >> 
> >> >> >> >> and send the /tmp/trace.
> >> >> >> >> Also, after the attempt fails, run
> >> >> >> >>  rpcdebug -m rpc -s cache
> >> >> >> >>  grep . /proc/net/rpc/*/c*
> >> >> >> >>  cat /proc/fs/nfsd/exports
> >> >> >> >> 
> >> >> >> >> and report the output.
> >> >> >> >> 
> >> >> >> > here:
> >> >> >> >
> >> >> >> > # cat /tmp/trace
> >> >> >> > pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL) = 1 (in [3])
> >> >> >> > read(3, "nfsd 10.0.0.1\n", 32768)       = 14
> >> >> >> > openat(AT_FDCWD, "/run/nfs/etab", O_RDONLY) = 14
> >> >> >> > fstat(14, {st_mode=S_IFREG|0644, st_size=435, ...}) = 0
> >> >> >> > close(14)                               = 0
> >> >> >> > write(3, "nfsd 10.0.0.1 2079 10.0.0.0/24 \n", 32) = 32
> >> >> >> 
> >> >> >> This is weird.
> >> >> >> Here mountd is telling nfsd that when a request comes from IP address
> >> >> >> 10.0.0.1, it should look for export entries associated with the client
> >> >> >> name "10.0.0.0/24", which is good.
> >> >> >> However the expiry time for that information is "2079", which is back in
> >> >> >> January 1970.
> >> >> >> When mountd writes that number, it computes it as
> >> >> >>    time(0) + DEFAULT_TTL
> >> >> >> where DEFAULT_TTL is (30 * 60)
> >> >> >> Which suggests time(0) is "279".
> >> >> >> 
> >> >> >> What is the current time on this system?
> >> >> >> 
> >> >> >> If it really was very early on Jan 1st 1970, it should work, however...
> >> >> >> 
> >> >> >> 
> >> >> >> > pselect6(1024, [3 4 5 7 8 9 10 11 12], NULL, NULL, NULL, NULL <detached ...>
> >> >> >> > # rpcdebug -m rpc -s cache
> >> >> >> > rpc        cache
> >> >> >> > # grep . /proc/net/rpc/*/c*
> >> >> >> > /proc/net/rpc/auth.unix.gid/content:#uid cnt: gids...
> >> >> >> > /proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
> >> >> >> > /proc/net/rpc/auth.unix.ip/channel:nfsd 10.0.0.1
> >> >> >> > /proc/net/rpc/auth.unix.ip/content:#class IP domain
> >> >> >> > /proc/net/rpc/auth.unix.ip/content:# expiry=2079 refcnt=1 flags=1
> >> >> >> > /proc/net/rpc/auth.unix.ip/content:# nfsd 10.0.0.1 10.0.0.0/24
> >> >> >> 
> >> >> >> ...the fact that this line is commented out indicates that the entry in
> >> >> >> the cache is already expired.  So the time must be after 2079.
> >> >> >> 
> >> >> >> Maybe the time is getting set from the network at an awkward time that
> >> >> >> races with NFS service some how.
> >> >> >> Can you find a way to run "exportfs -f" after the time has been set
> >> >> >> correctly?
> >> >> >> 
> >> >> >> NeilBrown
> >> >> >> 
> >> >> >> 
> >> >> >
> >> >> > wait, I think I've seen this somewhere, does this feature needs rtc? this board doesn't have rtc component.
> >> >> > for example, I cannot use openssh as ssh server because it needs rtc. I have to use dropbear.
> >> >> > if so, this looks like it will affect nfsv3 mounts, am I right?
> >> >> 
> >> >> No, you shouldn't need an RTC.
> >> >> You need the synchronize the clock with ntp or similar, else time stamps
> >> >> on files will look wrong.
> >> >> Though I think we fixed issues with wall-clock-time jumping in 2.6.37...
> >> >> 
> >> >> If you could try using "exportfs -f", and explain what does happen with
> >> >> time - do you use ntp ?? - we might be able to make progress.
> >> >
> >> > I'll build ntp into the image and try. does this affects nfsv3 too?
> >> 
> >> Having correct time is quite important for any version of NFS.  With out
> >> it, time stamps on files get confused.  "make" doesn't cope at all,
> >> "tar" often complains, other tools might experience other problems.
> >> 
> >> I still cannot quite see why having an incorrect clock would cause the
> >> particular symptoms you are experiencing, but it is worth fixing anyway.
> > I worked around the issue by setting the date manually. the issue still presists.
> >
> >> 
> >> >
> >> > what should I do with the "exportfs -f"? jsut run it and retry?
> >> 
> >> Yes.
> > exportfs -f didn't made any difference.
> 
> OK. Please:
>  - make sure the time is (nearly) correct - e.g. running date manually.
>  - run "exportfs -f"
>  - run "strace" on mountd
>  - try to mount the filesystem
>  - stop the strace
>  - run
>       rpcdebug -m rpc -s cache
>       grep . /proc/net/rpc/*/*
>       cat /proc/fs/nfsd/exports
> 
>   (note that it isn't quite the same 'grep' as before).
> 
> then post the output of the 'strace', the 'grep', and the 'cat'.
> 

so it took so long, I was able to fix the timer issue and now indeed I can mount as nfsv4.
but I've encountered another issue, copying a large file over nfs takes 3 minutes longer with nfsv4 than nfsv3.
I want to be sure this isn't a config issue, so here is the config:
# cat /etc/exports 
/mnt/media      10.0.0.0/24(rw,no_subtree_check,nohide,insecure)

the kernel in question is based on 3.14 (yeah, I know it is old but that is currently the only kernel fully supports the board in question).

can it be the config or the kernel?

Thanks,

Dagg.
