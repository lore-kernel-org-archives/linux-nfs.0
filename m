Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48496 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678Ab1AHBat convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jan 2011 20:30:49 -0500
In-Reply-To: <20110108005203.GD24433@hostway.ca>
References: <20101208212505.GA18192@hostway.ca>
	<20101218010801.GE28367@hostway.ca>
	<20101229220313.GA13688@hostway.ca>
	<AANLkTinq074Q-B=5B4_aXuBm-3ELwGknsJv+OvS1z1OX@mail.gmail.com>
	<20110104214008.GH27727@hostway.ca>
	<AANLkTim6HoN5+m180-Du+oda+6N49qSaGga6ktMPV4U4@mail.gmail.com>
	<AANLkTinLsREtOqNGW2j5m0UYros1AgTu953JHjjJZ-F+@mail.gmail.com>
	<20110108005203.GD24433@hostway.ca>
Date: Fri, 7 Jan 2011 17:30:46 -0800
Message-ID: <AANLkTi=6OydKWE+gpo5vgQ1DWgDOiRRAjFB_c2ABehgG@mail.gmail.com>
Subject: Re: System CPU increasing on idle 2.6.36
From: Mark Moseley <moseleymark@gmail.com>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jan 7, 2011 at 4:52 PM, Simon Kirby <sim@hostway.ca> wrote:
> On Fri, Jan 07, 2011 at 10:05:39AM -0800, Mark Moseley wrote:
>
>> NOTE: NFS/Kernel guys: I've left the 2.6.36.2 box still thrashing
>> about in case there's something you'd like me to look at.
>>
>> Ok, both my 2.6.36.2 kernel box and my 2.6.35->2.6.36 bisect box (was
>> bisected to ce7db282a3830f57f5b05ec48288c23a5c4d66d5 -- this is my
>> first time doing bisect, so I'll preemptively apologize for doing
>
> That's a merge commit, so that doesn't sound right (it doesn't contain
> changes by itself).  How were you running the bisect?  Were you
> definitely seeing a good case since v2.6.35?  Could you post your
> "git bisect log" so I can see if I can follow it?

Here's 'git bisect log':

# git bisect log
git bisect start
# bad: [f6f94e2ab1b33f0082ac22d71f66385a60d8157f] Linux 2.6.36
git bisect bad f6f94e2ab1b33f0082ac22d71f66385a60d8157f
# good: [9fe6206f400646a2322096b56c59891d530e8d51] Linux 2.6.35
git bisect good 9fe6206f400646a2322096b56c59891d530e8d51
# good: [78417334b5cb6e1f915b8fdcc4fce3f1a1b4420c] Merge branch
'bkl/core' of git://git.kernel.org/pub/scm/linux/kernel/git/frederic/random-tracing
git bisect good 78417334b5cb6e1f915b8fdcc4fce3f1a1b4420c
# good: [14a4fa20a10d76eb98b7feb25be60735217929ba] Merge branch
'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound-2.6
git bisect good 14a4fa20a10d76eb98b7feb25be60735217929ba
# bad: [ce7db282a3830f57f5b05ec48288c23a5c4d66d5] Merge branch
'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu
git bisect bad ce7db282a3830f57f5b05ec48288c23a5c4d66d5

I did an initial checkout of stable
(git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git)
and (after git bisect start), did a 'git bisect good v2.6.35; git
bisect bad v2.6.36' but that seemed to be way too old. I tried to
approximate 2.6.35.9->2.6.36 by doing 'git bisect good
ea8a52f9f4bcc3420c38ae07f8378a2f18443970; git bisect bad
f6f94e2ab1b33f0082ac22d71f66385a60d8157f' but that had compilation
errors so I did 'git bisect good
9fe6206f400646a2322096b56c59891d530e8d51' which compiled ok -- heh,
did I mention this was my first outing with 'git bisect' :)


> Yeah, I was seeing load proportional to these, but I don't think their
> growth is anything wrong.  It just seems to be something that is taking
> up CPU from flush proceses as they grow, and something which is causing a
> thundering herd of reclaim with lots of spinlock contention.
>
> Hmmm.. I tried to see if drop_caches would clear nfs_inode_cache and thus
> the CPU usage.  The top of slabtop before doing anything:
>
>  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
> 1256343 1221799  97%    0.95K  38071       33   1218272K nfs_inode_cache
>
> # echo 2 > /proc/sys/vm/drop_caches
>
> this took about 40 seconds to execute, and perf top showed this for
> pretty much the whole time:
>
>             samples  pcnt function                 DSO
>             _______ _____ ________________________ ___________
>
>             1188.00 45.1% _raw_spin_lock           [kernel]
>              797.00 30.2% rpcauth_cache_shrinker   [kernel]
>              132.00  5.0% shrink_slab              [kernel]
>               60.00  2.3% queue_io                 [kernel]
>               59.00  2.2% _cond_resched            [kernel]
>               44.00  1.7% nfs_writepages           [kernel]
>               35.00  1.3% writeback_single_inode   [kernel]
>               34.00  1.3% writeback_sb_inodes      [kernel]
>               23.00  0.9% do_writepages            [kernel]
>               20.00  0.8% bit_waitqueue            [kernel]
>               15.00  0.6% redirty_tail             [kernel]
>               11.00  0.4% __iget                   [kernel]
>               11.00  0.4% __GI_strstr              libc-2.7.so
>
> slabtop then showed:
>
>  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
> 1256211 531720  42%    0.95K  38067       33   1218144K nfs_inode_cache
>
> and this doesn't change further with drop_caches=3 or 1.  It's strange
> that most of them were freed, but not all...  We do actually have
> RPC_CREDCACHE_DEFAULT_HASHBITS set to 10 at build time, which might
> explain a bigger credcache and time to free that.  Did you change your
> auth_hashtable_size at all?  Anyway, even with all of that, system CPU
> doesn't change.

Oh, now that's interesting. I'm setting RPC_CREDCACHE_DEFAULT_HASHBITS
to 8 (and have been since Jan, so like 2.6.33 or something) -- I was
having the same issue as in this thread,
http://www.spinics.net/lists/linux-nfs/msg09261.html. Bumping up
RPC_CREDCACHE_DEFAULT_HASHBITS was like a miracle on some of our
systems. I was going to get around to switching to the 'right way' to
do that as a boot param one of these days, instead of a hack.

In the bisected kernel, I definitely did *not* touch
RPC_CREDCACHE_DEFAULT_HASHBITS and it blew up anyway. If it hadn't
completely died, it'd have been nice to see what 'perf top' said.


> Ok, weird, Running "sync" actually caused "vmstat 1" to go from 25% CPU
> spikes every 5 seconds with nfs_writepages in the "perf top" every 5
> seconds to being idle!  /proc/vmstat showed only nr_dirty 8 and
> nr_writeback 0 before I ran "sync".  Either that, or it was just good
> timing.
>
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
>  0  0      0 6767892   9696  41088    0    0     5   180   15   70 62  7 29  1
>  0  0      0 6767892   9696  41088    0    0     0     0 1124 1978  0  0 100  0
>  0  0      0 6767892   9696  41088    0    0     0     0 1105 1967  0  0 100  0
>  0  0      0 6767892   9696  41088    0    0     0     0 1180 1984  0  2 98  0
>  2  0      0 6767892   9696  41088    0    0     0     0 2102 1968  0 22 78  0
>  0  0      0 6767768   9704  41084    0    0     0    52 1504 2022  0  8 91  1
>  0  0      0 6767768   9704  41084    0    0     0     0 1059 1965  0  0 100  0
>  0  0      0 6767768   9704  41088    0    0     0     0 1077 1982  0  0 100  0
>  0  0      0 6767768   9704  41088    0    0     0     0 1166 1972  1  2 97  0
>  0  0      0 6767768   9704  41088    0    0     0     0 1353 1990  0  6 94  0
>  0  0      0 6767644   9704  41100    0    0     0     0 2531 2050  0 27 72  0
>  0  0      0 6767644   9704  41100    0    0     0     0 1065 1974  0  0 100  0
>  1  0      0 6767644   9704  41100    0    0     0     0 1090 1967  0  0 100  0
>  0  0      0 6767644   9704  41100    0    0     0     0 1175 1971  0  2 98  0
>  0  0      0 6767644   9704  41100    0    0     0     0 1321 1967  0  6 94  0
>  1  0      0 6767644   9712  41100    0    0     0    52 1995 1995  0 18 81  1
>  0  0      0 6767644   9712  41100    0    0     0     0 1342 1964  0  6 94  0
>  0  0      0 6767644   9712  41100    0    0     0     0 1064 1974  0  0 100  0
>  0  0      0 6767644   9712  41100    0    0     0     0 1163 1968  0  2 98  0
>  0  0      0 6767644   9712  41100    0    0     0     0 1390 1976  1  6 94  0
>  0  0      0 6767768   9712  41112    0    0     0     0 1282 2018  0  1 99  0
>  0  0      0 6767768   9712  41112    0    0     0     0 2166 1972  0 24 76  0
>  0  0      0 6786260   9712  41112    0    0     0     0 1092 1989  0  0 100  0
>  0  0      0 6786260   9712  41112    0    0     0     0 1039 2003  0  2 98  0
>  0  0      0 6774588   9712  41112    0    0     0     0 1524 2015  3  9 89  0
>  0  1      0 6770124   9716  41112    0    0     0    48 1315 1990  3  0 87 11
>  1  0      0 6769628   9720  41112    0    0     0     4 2196 1966  0 20 79  0
>  0  0      0 6768364   9724  41108    0    0    36     0 1403 2031  1  5 94  1
>  0  0      0 6768388   9724  41144    0    0     0     0 1185 1969  0  2 98  0
>  0  0      0 6768388   9724  41144    0    0     0     0 1351 1975  0  6 94  0
>  0  0      0 6768140   9724  41156    0    0     0     0 1261 2020  0  1 99  0
>  0  0      0 6768140   9724  41156    0    0     0     0 1053 1973  0  0 100  0
>  1  0      0 6768140   9724  41156    0    0     0     0 2194 1971  1 26 73  0
>  0  0      0 6768140   9732  41148    0    0     0    52 1283 2088  0  4 96  0
>  2  0      0 6768140   9732  41156    0    0     0     0 1184 1965  0  2 98  0
>  0  0      0 6786368   9732  41156    0    0     0     0 1297 2000  0  4 97  0
>  0  0      0 6786384   9732  41156    0    0     0     0  998 1949  0  0 100  0
> (stop vmstat 1, run sync, restart vmstat 1)
>  1  0      0 6765304   9868  41736    0    0     0     0 1239 1967  0  0 100  0
>  0  0      0 6765304   9868  41736    0    0     0     0 1174 2035  0  0 100  0
>  0  0      0 6765304   9868  41736    0    0     0     0 1084 1976  0  0 100  0
>  1  0      0 6765172   9868  41736    0    0     0     0 1100 1975  0  0 100  0
>  0  0      0 6765304   9868  41760    0    0     0     0 1501 1997  1  1 98  0
>  0  0      0 6765304   9868  41760    0    0     0     0 1092 1964  0  0 100  0
>  1  0      0 6765304   9868  41760    0    0     0     0 1096 1963  0  0 100  0
>  0  0      0 6765304   9868  41760    0    0     0     0 1083 1967  0  0 100  0
>  0  0      0 6765304   9876  41752    0    0     0    76 1101 1980  0  0 99  1
>  0  0      0 6765304   9876  41760    0    0     0     4 1199 2097  0  2 98  0
>  0  0      0 6765304   9876  41760    0    0     0     0 1055 1964  0  0 100  0
>  0  0      0 6765304   9876  41760    0    0     0     0 1064 1977  0  0 100  0
>  0  0      0 6765304   9876  41760    0    0     0     0 1073 1968  0  0 100  0
>  0  0      0 6765304   9876  41760    0    0     0     0 1080 1976  0  0 100  0
>  0  0      0 6765156   9884  41772    0    0     0    20 1329 2034  1  1 98  1
>  0  0      0 6765180   9884  41780    0    0     0     0 1097 1971  0  1 99  0
>  0  0      0 6765180   9884  41780    0    0     0     0 1073 1960  0  0 100  0
>  0  0      0 6765180   9884  41780    0    0     0     0 1079 1976  0  0 100  0
>  0  0      0 6765172   9884  41780    0    0     0     0 1120 1980  0  0 100  0
>  0  0      0 6765180   9892  41772    0    0     0    60 1097 1982  0  0 100  0
>  0  0      0 6765180   9892  41780    0    0     0     0 1067 1969  0  0 100  0
>  0  0      0 6765180   9892  41780    0    0     0     0 1063 1973  0  0 100  0
>  0  0      0 6765180   9892  41780    0    0     0     0 1064 1969  0  1 100  0
>
> Hmmm.  I'll watch it and see if it climbs back up again.  That would mean
> that for now, echo 2 > /proc/sys/vm/drop_caches ; sync is a workaround
> for the problem we're seeing with system CPU slowly creeping up since
> 2.6.36.  I have no idea if this affects the sudden flush process spinlock
> contention and attempted writeback without much progress during normal
> load, but it certainly changes things here.
>
> http://0x.ca/sim/ref/2.6.37/cpu_after_drop_caches_2_and_sync.png

That's pretty painful to have to do though (less painful than the box
becoming unusable, I'll admit). I wonder if when I did a umount on
mine (which must've sync'd at least that mount), it gave something a
big enough kick for the flush-0:xx threads to unstick themselves,
presumably what happened with your sync (though I didn't drop the
cache).
