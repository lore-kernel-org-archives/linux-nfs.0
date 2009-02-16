Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-10-54-97-Michigan.hfc.comcastbusiness.net ([173.10.54.97]:56050
	"EHLO crunch.scalableinformatics.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755975AbZBPNeC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Feb 2009 08:34:02 -0500
Message-ID: <499968F0.8000509@scalableinformatics.com>
Date: Mon, 16 Feb 2009 08:24:00 -0500
From: Joe Landman <landman@scalableinformatics.com>
Reply-To: landman@scalableinformatics.com
To: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
CC: beowulf@beowulf.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: Tracing down 250ms open/chdir calls
References: <49991BE7.1090104@aei.mpg.de>
In-Reply-To: <49991BE7.1090104@aei.mpg.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Carsten Aulbert wrote:
> Hi all,
> 
> sorry in advance for this vague subject and also the vague email, I'm
> trying my best to summarize the problem:
> 
> On our large cluster we sometimes encounter the problem that our main
> scheduling processes are often in state D and in the end not capable
> anymore of pushing work to the cluster.

Hi Carsten

   Are you using a "standard" cluster scheduler (SGE, PBS, ...) or a 
locally written one?

> The head nodes are 8 core boxes with Xeon CPUs and equipped with 16 GB
> of memory, when certain types of jobs are running we see system loads of
> about 20-30 which might go up to 80-100 from time to time. Looking at
> the individual cores they are mostly busy with system tasks (e.g. htop
> shows 'red' bars).

Hmmm...  These are your head nodes?  Not your NFS server nodes?  Sounds 
like there are a large number of blocked IO processes ... try a

	vmstat 1

and look at the "b" column (usually second from left ... or nearly 
there).  Lots of blocked IO processes can have the affect of introducing 
significant latency into all system calls.

> stat -tt -c showed that several system calls of the scheduler take a
> long time to complete, most notably open and chdir which took between
> 180 and 230ms to complete (during our testing). Since most of these open
> and chdir are via NFSv3 I'm including that list as well. The NFS servers
> are Sun Fire X4500 boxes running Solaris 10u5 right now.

Hmmm.... What happens if you make these local to each box?  What are the 
mount options for the mount points?  We have spoken to other users with 
performance problems on such servers.  The NFS server/OS combination you 
indicate above isn't known to be very fast.  This isn't your problem 
(see later), but it looks like your own data suggests you are giving up 
nearly an order of magnitude performance using this NFS server/OS 
combination, likely at a premium price as well.

> A standard output line looks like:
> 93.37   38.997264     230753      169    78      open
> 
> i.e. 93.37% of the system-related time was spend in 169 successful open
> calls which took 230753us/call, thus 39 wall clock seconds were spend in
> a minute just doing open.
> 
> We tried several things to understand the problem, but apart from moving
> more files (mostly log files of currently running jobs) off NFS we did
> not move far ahead so far. On
> https://n0.aei.uni-hannover.de/twiki/bin/view/ATLAS/H2Problems
> we have summarized some things.

I didn't catch if these are tcp/udp mounts.  What are the mount options?

> With the help of 'stress' and a tiny program just doing open/putc/close
> into a single file, I've tried to get a feeling how good or bad things
> are when compared to other head nodes with different tasks/loads:
> 
> https://n0.aei.uni-hannover.de/twiki/bin/view/ATLAS/OpenCloseIotest

... and these results do in fact confirm the comment I made about the 
NFS server/OS combo not known to be fast.

 From my laptop running a Ubuntu 8.10 variant over gigabit to a known 
very slow NFS server ...

./measure.exe /misc/crunch/home/landman/test2
Wrote 24905 times into /misc/crunch/home/landman/test2, speed is 
421.14/s, time elapsed: 59.14s


from a different server in a different location to a JackRabbit-S server 
over NFS on a single gigabit with default mounts (this server running a 
long IOzone)

./measure.exe /mnt/d/1
Wrote 124312 times into /mnt/d/1, speed is 2072.99/s, time elapsed: 59.97s

and from the same starting point but to a JackRabbit-S server over NFS 
on a single gigabit with default mounts (this server idle)

./measure.exe /mnt/d/x
Wrote 134426 times into /mnt/d/x, speed is 2270.79/s, time elapsed: 59.20s

This system would be roughly similar to your d02 machine.

ly
Assuming you aren't using mount options of noac,sync,...  Could you 
enlighten us as to what mount options are for the head nodes?

Also, the way the code is written, you are doing quite a few calls to 
gettimeofday ... you could probably avoid this with a little re-writing 
of the main loop.

If you are using noac or sync on your NFS mounts, then this could 
explain some of the differences you are seeing (certainly the 100/s vs 
800/s ... but not likely the 4/s)

However, if you notice that h2 in your table is an apparent outlier, 
there may be something more systematic going on there.  Since you 
indicate there is a high load going on while you are testing, this is 
likely what you need to explore.

Grab the atop program.  It is pretty good about letting you explore what 
is causing load.  That is, despite your x4500's/Solaris combo showing 
itself not to be a fast NFS server the problem appears to be more likely 
more localized on the h2 machine than on the NFS machines.

http://freshmeat.net/projects/atop/

Joe

-- 
Joseph Landman, Ph.D
Founder and CEO
Scalable Informatics LLC,
email: landman@scalableinformatics.com
web  : http://www.scalableinformatics.com
        http://jackrabbit.scalableinformatics.com
phone: +1 734 786 8423 x121
fax  : +1 866 888 3112
cell : +1 734 612 4615
